package types

import (
	"github.com/cosmos/cosmos-sdk/codec"
	"github.com/cosmos/cosmos-sdk/codec/types"
	cryptocodec "github.com/cosmos/cosmos-sdk/crypto/codec"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/cosmos/cosmos-sdk/types/msgservice"
)

var (
	amino     = codec.NewLegacyAmino()
	ModuleCdc = codec.NewAminoCodec(amino)
)

func RegisterLegacyAminoCodec(cdc *codec.LegacyAmino) {
	cdc.RegisterConcrete(&MsgSubmitQueryResponse{}, "/stride.interchainquery.MsgSubmitQueryResponse", nil)
	cdc.RegisterConcrete(&MsgQueryExchangerate{}, "interchainquery/QueryExchangerate", nil)
	cdc.RegisterConcrete(&MsgQueryDelegatedbalance{}, "interchainquery/QueryDelegatedbalance", nil)
	// this line is used by starport scaffolding # 2
}

func RegisterInterfaces(registry types.InterfaceRegistry) {
	registry.RegisterImplementations((*sdk.Msg)(nil),
		&MsgSubmitQueryResponse{},
		&MsgQueryBalance{},
		&MsgQueryExchangerate{},
		&MsgQueryDelegatedbalance{},
	)
	// this line is used by starport scaffolding # 3

	msgservice.RegisterMsgServiceDesc(registry, &_Msg_serviceDesc)
}
func init() {
	RegisterLegacyAminoCodec(amino)
	cryptocodec.RegisterCrypto(amino)
	amino.Seal()
}
