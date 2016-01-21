exports.ParamTypes =
  string: 'String'
  number: 'Number'
  ami: 'AWS::EC2::Image::Id'

exports.ResourceTypes =
  stack: 'AWS::CloudFormation::Stack'
  alarm: 'AWS::CloudWatch::Alarm'
  queue: 'AWS::SQS::Queue'
  dynamoTable: 'AWS::DynamoDB::Table'
  elb: 'AWS::ElasticLoadBalancing::LoadBalancer'
  asg: 'AWS::AutoScaling::AutoScalingGroup'
  scalingPolicy: 'AWS::AutoScaling::ScalingPolicy'
  launchConfig: 'AWS::AutoScaling::LaunchConfiguration'
  lifecycleHook: 'AWS::AutoScaling::LifecycleHook'
  redshiftIngress: 'AWS::Redshift::ClusterSecurityGroupIngress'
  securityGroup: 'AWS::EC2::SecurityGroup'
  ingress: 'AWS::EC2::SecurityGroupIngress'

exports.KeyValList = [
  'Dimensions'
  # 'Tags' # TODO: PropagateAtLaunch?
]
