ACTION=$1

case $ACTION in
  create)
    aws cloudformation create-stack \
    --stack-name $2 \
    --template-body file://$3 \
    --parameters file://$4 \
    --region=$5
    ;;

  update)
    aws cloudformation update-stack \
    --stack-name $2 \
    --template-body file://$3 \
    --parameters file://$4
    ;;

  delete)
    aws cloudformation delete-stack \
    --stack-name $1 \
    --region=$5
    ;;

  *)
    echo -n "invalid action, expecting (create | update | delete)"
    ;;
esac