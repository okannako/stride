package keeper

import (
	"testing"
	"time"

	sdk "github.com/cosmos/cosmos-sdk/types"
	tmproto "github.com/tendermint/tendermint/proto/tendermint/types"

	strideapp "github.com/Stride-Labs/stride/app"
	"github.com/Stride-Labs/stride/x/stakeibc/keeper"
)

func StakeibcKeeper(t testing.TB) (*keeper.Keeper, sdk.Context) {
	checkTx := false
	app := strideapp.InitTestApp(checkTx)
	stakeibcKeeper := app.StakeibcKeeper
	ctx := app.BaseApp.NewContext(checkTx, tmproto.Header{Height: 1, ChainID: "stride-1", Time: time.Now().UTC()})

	return &stakeibcKeeper, ctx
}
// CHANGES