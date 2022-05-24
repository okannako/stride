package keeper

import (
	"time"

	"github.com/Stride-Labs/stride/x/stakeibc/types"
	"github.com/Stride-Labs/cosmos-sdk/telemetry"
	sdk "github.com/Stride-Labs/cosmos-sdk/types"
)

// BeginBlocker of stakeibc module
func (k Keeper) BeginBlocker(ctx sdk.Context) {
	defer telemetry.ModuleMeasureSince(types.ModuleName, time.Now(), telemetry.MetricKeyBeginBlocker)
	
}