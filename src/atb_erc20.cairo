use starknet::ContractAddress;
//name,symbol,decimals,totalsupply,mint,transfer,withdraw, approve, transfer_from
#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u32;
    fn total_supply(self: @TContractState) -> u64;
    fn mint(ref self: TContractState, address: ContractAddress, amount: u64) -> bool;
    fn balance_of(ref self: TContractState, address: ContractAddress) -> u64;
    fn withdraw(ref self: TContractState, address: ContractAddress, amount: u32) -> bool;
    fn transfer(ref self: TContractState, address: ContractAddress, amount: u32) -> bool;
    fn approve(ref self: TContractState, address: ContractAddress, amount: u32) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, receiver: ContractAddress, amount: u32,
    ) -> bool;
}

#[starknet::contract]
mod ATB_ERC20 {
    use core::num::traits::Zero;
    use starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u32,
        total_supply: u64,
        balance: Map<ContractAddress, u64>,
    }

    #[constructor]
    // fn constructor(
    //     ref self: ContractState, _name: felt252, _symbol: felt252, decimal: u32, totalsupply:
    //     u32,
    // ) -> bool {
    //     self.name.write(_name);
    //     self.symbol.write(_symbol);
    //     self.decimals.write(decimal);
    //     self.total_supply.write(totalsupply);

    //     true
    // }

    fn constructor(ref self: ContractState) -> bool {
        self.name.write('AnambraTechies');
        self.symbol.write('ATB');
        self.decimals.write('18');
        self.total_supply.write('0');
        true
    }


    #[abi(embed_v0)]
    impl IERC20Impl of super::IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }
        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }
        fn decimals(self: @ContractState) -> u32 {
            self.decimals.read()
        }
        fn total_supply(self: @ContractState) -> u64 {
            self.total_supply.read()
        }
        fn mint(ref self: ContractState, address: ContractAddress, amount: u64) -> bool {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Caller is 0 address');
            let old_balance = self.balance.entry(caller).read();
            let account_balance = old_balance + amount;
            self.balance.entry(caller).write(account_balance);
            let prev_supply = self.total_supply.read();
            let current_supply = prev_supply + amount;
            self.total_supply.write(current_supply);
            true
        }
        fn balance_of(ref self: ContractState, address: ContractAddress) -> u64 {}
        fn withdraw(ref self: ContractState, address: ContractAddress, amount: u32) -> bool {}
        fn transfer(ref self: ContractState, address: ContractAddress, amount: u32) -> bool {}
        fn approve(ref self: ContractState, address: ContractAddress, amount: u32) -> bool {}
        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            receiver: ContractAddress,
            amount: u32,
        ) -> bool {}
    }
}
