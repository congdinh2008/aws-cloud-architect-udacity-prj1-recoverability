ACTION=$1
STACK="secondary"
TEMPLATE="vpc.yaml"
PARAMS="secondary_parameters.json"
REGION="us-west-2"

./create_vpc.sh $ACTION $STACK $TEMPLATE $PARAMS $REGION