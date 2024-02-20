
# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "gum is not installed. Please install it from: https://github.com/charmbracelet/gum"
    exit 1
fi

# Check if freeport is installed
if ! command -v freeport &> /dev/null; then
    echo "freeport is not installed. Please install it from: https://github.com/phayes/freeport"
    exit 1
fi

# Continue with your script if wget is installed
echo "wget is installed. Proceeding with the script..."

RESOURCE_TYPE=$(gum choose pod service --limit 1)
RESOURCE_NAME=$(kubectl get $RESOURCE_TYPE -o custom-columns=:metadata.name |tail -n +2 |gum filter --fuzzy --sort --limit=1 --indicator="⟢")
if [ "$RESOURCE_TYPE" = "pod" ]; then
    RESOURCE_PORT=$(kubectl get $RESOURCE_TYPE $RESOURCE_NAME -o=jsonpath='{.spec.containers[*].ports[*]}'| grep -o '"containerPort":[0-9]*' | awk -F: '{print $2}'|gum choose --limit 1)
else
    RESOURCE_PORT=$(kubectl get service jaeger -o=jsonpath='{.spec.ports[*].port}'| tr ' ' '\n'|gum choose --limit 1)
fi
FREE_PORT=$(freeport)
echo "🚀 kubectl port-forward $RESOURCE_TYPE/$RESOURCE_NAME :$RESOURCE_PORT" | gum format -t emoji
echo $FREE_PORT |pbcopy
echo "🔗 http://localhost:$FREE_PORT" |gum format -t emoji
echo "😉 copied port to clipboard"|gum format -t emoji
gum spin --spinner dot --title "Forwarding" --show-output -- kubectl port-forward $RESOURCE_TYPE/$RESOURCE_NAME $FREE_PORT:$RESOURCE_PORT
