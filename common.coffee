exports.ParamTypes =
  string: 'String'
  number: 'Number'
  ami:    'AWS::EC2::Image::Id'

exports.ResourceTypes =
  asg:             'AWS::AutoScaling::AutoScalingGroup'
  launchConfig:    'AWS::AutoScaling::LaunchConfiguration'
  lifecycleHook:   'AWS::AutoScaling::LifecycleHook'
  scalingPolicy:   'AWS::AutoScaling::ScalingPolicy'
  scheduledAction: 'AWS::AutoScaling::ScheduledAction'

  stack: 'AWS::CloudFormation::Stack'

  alarm: 'AWS::CloudWatch::Alarm'

  dynamoTable: 'AWS::DynamoDB::Table'

  elasticIp:     'AWS::EC2::EIP'
  instance:      'AWS::EC2::Instance'
  securityGroup: 'AWS::EC2::SecurityGroup'
  ingress:       'AWS::EC2::SecurityGroupIngress'
  subnet:        'AWS::EC2::Subnet'
  vpc:           'AWS::EC2::VPC'

  elb: 'AWS::ElasticLoadBalancing::LoadBalancer'

  redshiftIngress: 'AWS::Redshift::ClusterSecurityGroupIngress'

  queue: 'AWS::SQS::Queue'

exports.ReferenceBuiltins =
  accountId:        'AWS::AccountId'
  notificationARNs: 'AWS::NotificationARNs'
  noValue:          'AWS::NoValue'
  region:           'AWS::Region'
  stackId:          'AWS::StackId'
  stackName:        'AWS::StackName'

exports.KeyValList = [
  'Dimensions'
  # 'Tags' # TODO: PropagateAtLaunch?
]
