import json
import boto3
import os
import logging
from typing import List, Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event: Dict[str, Any], context) -> Dict[str, Any]:
    """
    Lambda function handler for pausing/resuming ECS and RDS resources.
    
    Args:
        event: Lambda event containing action ('pause' or 'resume')
        context: Lambda context object
        
    Returns:
        Dict with status and results
    """
    try:
        action = event.get('action', 'pause')
        environment_name = os.environ.get('ENVIRONMENT_NAME', 'unknown')
        
        logger.info(f"Starting {action} operation for environment: {environment_name}")
        
        results = {
            'action': action,
            'environment': environment_name,
            'ecs_results': [],
            'rds_results': [],
            'errors': []
        }
        
        # Handle ECS services
        ecs_results = handle_ecs_services(action)
        results['ecs_results'] = ecs_results
        
        # Handle RDS instances
        rds_results = handle_rds_resources(action)
        results['rds_results'] = rds_results
        
        logger.info(f"Completed {action} operation")
        
        return {
            'statusCode': 200,
            'body': json.dumps(results)
        }
        
    except Exception as e:
        logger.error(f"Error in {action} operation: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'action': action
            })
        }

def handle_ecs_services(action: str) -> List[Dict[str, Any]]:
    """Handle ECS service pause/resume operations."""
    results = []
    
    try:
        ecs_client = boto3.client('ecs')
        cluster_name = os.environ.get('ECS_CLUSTER_NAME')
        service_names = os.environ.get('ECS_SERVICE_NAMES', '').split(',')
        service_names = [name.strip() for name in service_names if name.strip()]
        
        if not cluster_name or not service_names:
            logger.info("No ECS cluster or services configured")
            return results
            
        for service_name in service_names:
            try:
                if action == 'pause':
                    # Scale down to 0 tasks
                    response = ecs_client.update_service(
                        cluster=cluster_name,
                        service=service_name,
                        desiredCount=0
                    )
                    logger.info(f"Paused ECS service: {service_name}")
                    
                elif action == 'resume':
                    # Scale up to 1 task (or retrieve previous desired count from tags/parameter store)
                    response = ecs_client.update_service(
                        cluster=cluster_name,
                        service=service_name,
                        desiredCount=1  # Default to 1, could be made configurable
                    )
                    logger.info(f"Resumed ECS service: {service_name}")
                
                results.append({
                    'service': service_name,
                    'cluster': cluster_name,
                    'status': 'success',
                    'desired_count': response['service']['desiredCount']
                })
                
            except Exception as e:
                logger.error(f"Error handling ECS service {service_name}: {str(e)}")
                results.append({
                    'service': service_name,
                    'cluster': cluster_name,
                    'status': 'error',
                    'error': str(e)
                })
                
    except Exception as e:
        logger.error(f"Error in ECS operations: {str(e)}")
        results.append({
            'status': 'error',
            'error': f"ECS client error: {str(e)}"
        })
    
    return results

def handle_rds_resources(action: str) -> List[Dict[str, Any]]:
    """Handle RDS instance and cluster pause/resume operations."""
    results = []
    
    try:
        rds_client = boto3.client('rds')
        
        # Handle RDS instances
        instance_identifiers = os.environ.get('RDS_INSTANCE_IDENTIFIERS', '').split(',')
        instance_identifiers = [id.strip() for id in instance_identifiers if id.strip()]
        
        for instance_id in instance_identifiers:
            try:
                if action == 'pause':
                    rds_client.stop_db_instance(
                        DBInstanceIdentifier=instance_id
                    )
                    logger.info(f"Stopped RDS instance: {instance_id}")
                    
                elif action == 'resume':
                    rds_client.start_db_instance(
                        DBInstanceIdentifier=instance_id
                    )
                    logger.info(f"Started RDS instance: {instance_id}")
                
                results.append({
                    'resource_type': 'instance',
                    'resource_id': instance_id,
                    'status': 'success'
                })
                
            except Exception as e:
                logger.error(f"Error handling RDS instance {instance_id}: {str(e)}")
                results.append({
                    'resource_type': 'instance',
                    'resource_id': instance_id,
                    'status': 'error',
                    'error': str(e)
                })
        
        # Handle RDS clusters
        cluster_identifiers = os.environ.get('RDS_CLUSTER_IDENTIFIERS', '').split(',')
        cluster_identifiers = [id.strip() for id in cluster_identifiers if id.strip()]
        
        for cluster_id in cluster_identifiers:
            try:
                if action == 'pause':
                    rds_client.stop_db_cluster(
                        DBClusterIdentifier=cluster_id
                    )
                    logger.info(f"Stopped RDS cluster: {cluster_id}")
                    
                elif action == 'resume':
                    rds_client.start_db_cluster(
                        DBClusterIdentifier=cluster_id
                    )
                    logger.info(f"Started RDS cluster: {cluster_id}")
                
                results.append({
                    'resource_type': 'cluster',
                    'resource_id': cluster_id,
                    'status': 'success'
                })
                
            except Exception as e:
                logger.error(f"Error handling RDS cluster {cluster_id}: {str(e)}")
                results.append({
                    'resource_type': 'cluster',
                    'resource_id': cluster_id,
                    'status': 'error',
                    'error': str(e)
                })
                
    except Exception as e:
        logger.error(f"Error in RDS operations: {str(e)}")
        results.append({
            'status': 'error',
            'error': f"RDS client error: {str(e)}"
        })
    
    return results