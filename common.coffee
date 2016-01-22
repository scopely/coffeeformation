exports.ParamTypes =
  string: 'String'
  number: 'Number'

  list:       'CommaDelimitedList'
  numberList: 'List<Number>'

  zone:          'AWS::EC2::AvailabilityZone::Name'
  ami:           'AWS::EC2::Image::Id'
  instance:      'AWS::EC2::Instance::Id'
  keyPair:       'AWS::EC2::KeyPair::KeyName'
  securityGroup: 'AWS::EC2::SecurityGroup::Id'
  subnet:        'AWS::EC2::Subnet::Id'
  volume:        'AWS::EC2::Volume::Id'
  vpc:           'AWS::EC2::VPC::Id'
  route53:       'AWS::Route53::HostedZone::Id'

  zoneList:          'List<AWS::EC2::AvailabilityZone::Name>'
  amiList:           'List<AWS::EC2::Image::Id>'
  instanceList:      'List<AWS::EC2::Instance::Id>'
  keyPairList:       'List<AWS::EC2::KeyPair::KeyName>'
  securityGroupList: 'List<AWS::EC2::SecurityGroup::Id>'
  subnetList:        'List<AWS::EC2::Subnet::Id>'
  volumeList:        'List<AWS::EC2::Volume::Id>'
  vpcList:           'List<AWS::EC2::VPC::Id>'
  route53List:       'List<AWS::Route53::HostedZone::Id>'

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
