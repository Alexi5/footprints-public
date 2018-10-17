require 'aws-sdk-elasticloadbalancingv2'
require 'aws-sdk-ec2'

class BlueGreenIpClient
  ELB_NAME='blue-green-elb'

  def initialize()
    @elb_client = Aws::ElasticLoadBalancingV2::Client.new(region: 'us-east-1')
    @ec2_client = Aws::EC2::Client.new(region: 'us-east-1')
  end

  # Get a hash of public IP addresses, where the key is the active/inactive
  # state, and the value is the public IP address
  def get_ips
    blue_green_elb_arn = get_blue_green_elb_arn()

    get_ips_from_blue_green_elb_arn(blue_green_elb_arn)
  end

  private

  def get_ips_from_blue_green_elb_arn(blue_green_elb_arn)
    active_target_group_arn = get_active_target_group_arn(blue_green_elb_arn)

    all_target_groups = get_all_target_groups()

    active_target_group   = all_target_groups.find{
      |t| t.target_group_arn == active_target_group_arn
    }

    inactive_target_group = all_target_groups.find{
      |t| t.target_group_arn != active_target_group_arn
    }

    active_ec2_id   = get_target_group_instance_id(
      active_target_group.target_group_arn
    )

    inactive_ec2_id = get_target_group_instance_id(
      inactive_target_group.target_group_arn
    )

    ips = {
      :active_ip   => get_ec2_public_ip_by_id(active_ec2_id),
      :inactive_ip => get_ec2_public_ip_by_id(inactive_ec2_id),
    }
  end

  def get_blue_green_elb_arn
    resp = @elb_client.describe_load_balancers

    blue_green_elb = resp.load_balancers.find{
      |elb| elb.load_balancer_name == BlueGreenIpClient::ELB_NAME
    }

    blue_green_elb.load_balancer_arn
  end

  def get_active_target_group_arn(load_balancer_arn)
    resp = @elb_client.describe_listeners({
      load_balancer_arn: load_balancer_arn,
    })

    resp.listeners[0].default_actions[0].target_group_arn
  end

  def get_all_target_groups()
    resp = @elb_client.describe_target_groups().target_groups
  end

  def get_target_group_instance_id(target_group_arn)
    resp = @elb_client.describe_target_health({
      target_group_arn: target_group_arn,
    })

    resp.target_health_descriptions[0].target.id
  end

  def get_ec2_public_ip_by_id(ec2_id)
    resp = @ec2_client.describe_instances({
      instance_ids: [
        ec2_id,
      ],
    })

    resp.reservations[0].instances[0].public_ip_address
  end
end