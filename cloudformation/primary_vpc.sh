ACTION=$1
STACK="primary"
TEMPLATE="vpc.yaml"
PARAMS="primary-parameters.json"
REGION="us-east-1"

./create_vpc.sh $ACTION $STACK $TEMPLATE $PARAMS $REGION