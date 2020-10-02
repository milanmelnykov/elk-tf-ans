#!/usr/bin/python
import sys
import json

try:
    import boto3
except Exception as e:
    print(e)
    print("Please rectify above exception and then try again")
    sys.exit(1)


def get_hosts(ec2_ob,fv):
    f={"Name":"tag:Env" , "Values": [fv]}
    hosts=[]
    for each_in in ec2_ob.instances.filter(Filters=[f]):
        hosts.append(each_in.private_ip_address)
    return hosts    

def main():
    ec2_ob=boto3.resource("ec2","us-east-1")
    elasticsearch_group=get_hosts(ec2_ob,'mielasticsearch')
    kibana_group=get_hosts(ec2_ob,'mikibana')
    logstash_group=get_hosts(ec2_ob,'milogstash')
    all_groups={ 'elasticsearch': elasticsearch_group, 'kibana': kibana_group,'logstash': logstash_group}
    print(json.dumps(all_groups))
    return None

if __name__=="__main__":
    main()