# this file should be called from the `stride` folder
# e.g. `sh ./scripts/init.sh`
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# import dependencies
source ${SCRIPT_DIR}/vars.sh

# cleanup any stale state
rm -rf $STATE
docker-compose down

# first, we need to create some saved state, so that we can copy to docker files
for chain_name in ${STRIDE_CHAINS[@]}; do
    mkdir -p ./$STATE/$chain_name
done

# fetch the stride node ids
STRIDE_NODES=()
# then, we initialize our chains 
echo 'Initializing chains...'
for i in ${!STRIDE_CHAINS[@]}; do
    chain_name=${STRIDE_CHAINS[i]}
    vkey=${VKEYS[i]}
    val_acct=${VAL_ACCTS[i]}
    st_cmd=${ST_CMDS[i]}
    echo "\t$chain_name"
    $st_cmd init test --chain-id $chain_name --overwrite 2> /dev/null
    sed -i -E 's|"stake"|"ustrd"|g' "${STATE}/${chain_name}/config/genesis.json"
    # add VALidator account
    echo $vkey | $st_cmd keys add $val_acct --recover --keyring-backend=test > /dev/null
    # get validator address
    VAL_ADDR=$($st_cmd keys show $val_acct --keyring-backend test -a)
    # add money for this validator account
    $st_cmd add-genesis-account ${VAL_ADDR} 500000000000ustrd
    # actually set this account as a validator
    yes | $st_cmd gentx $val_acct 1000000000ustrd --chain-id $main_chain --keyring-backend test
    # now we process these txs 
    $st_cmd collect-gentxs 2> /dev/null
    # now we grab the relevant node id
    dock_name=${STRIDE_DOCKER_NAMES[i]}
    node_id=$($st_cmd tendermint show-node-id)@$dock_name:$PORT_ID
    STRIDE_NODES+=( $node_id )

    if [ $i -ne $MAIN_ID ]
    then
        $main_cmd add-genesis-account ${VAL_ADDR} 500000000000ustrd
        cp ./${STATE}/${chain_name}/config/gentx/*.json ./${STATE}/${main_chain}/config/gentx/
    fi
done

$main_cmd collect-gentxs 2> /dev/null
# add peers in config.toml so that nodes can find each other by constructing a fully connected
# graph of nodes
for i in ${!STRIDE_CHAINS[@]}; do
    chain_name=${STRIDE_CHAINS[i]}
    peers=""
    for j in "${!STRIDE_NODES[@]}"; do
        if [ $j -ne $i ]
        then
            peers="${STRIDE_NODES[j]},${peers}"
        fi
    done
    echo 'peers are: '
    echo $peers
    sed -i -E "s|persistent_peers = \"\"|persistent_peers = \"$peers\"|g" "${STATE}/${chain_name}/config/config.toml"
done

# make sure all Stride chains have the same genesis
for i in "${!STRIDE_CHAINS[@]}"; do
    if [ $i -ne $MAIN_ID ]
    then
        cp ./${STATE}/${main_chain}/config/genesis.json ./${STATE}/${STRIDE_CHAINS[i]}/config/genesis.json
    fi
done

# strided start --home state/STRIDE_1  # TESTING ONLY

# next we build our docker images
# docker build --no-cache --pull --tag stridezone:stride -f Dockerfile.stride .  # builds from scratch
# docker build --tag stridezone:stride -f Dockerfile.stride .  # uses cache to speed things up

# finally we serve our docker images
sleep 5
docker-compose up -d stride1 stride2 stride3


