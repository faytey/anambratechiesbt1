use starknet::ContractAddress;
//name,symbol,decimals,totalsupply,mint,transfer,withdraw, approve, transfer_from
#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u32;
    fn total_supply(self: @TContractState) -> u64;
    fn mint(ref self: TContractState, address: ContractAddress, amount: u64) -> bool;
    fn balance_of(self: @TContractState, address: ContractAddress) -> u64;
    fn withdraw(ref self: TContractState, address: ContractAddress, amount: u64) -> bool;
    fn transfer(ref self: TContractState, address: ContractAddress, amount: u64) -> bool;
    fn allowance(self: @TContractState, sender: ContractAddress, receiver: ContractAddress) -> u64;
    fn approve(ref self: TContractState, address: ContractAddress, amount: u64) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, receiver: ContractAddress, amount: u64,
    ) -> bool;
}

#[starknet::contract]
mod ATB_ERC20 {
    use super::IERC20;
    use core::num::traits::Zero;
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
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
        owner: ContractAddress,
        allowances: Map<(ContractAddress, ContractAddress), u64>,
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
        self.owner.write(get_caller_address());
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
        fn balance_of(self: @ContractState, address: ContractAddress) -> u64 {
            self.balance.entry(address).read()
        }
        fn withdraw(ref self: ContractState, address: ContractAddress, amount: u64) -> bool {
            let caller: ContractAddress = get_caller_address();
            let contract = get_contract_address();
            let owner = self.owner.read();
            let contract_balance = self.balance.entry(contract).read();
            let callers_balance = self.balance.entry(caller).read();
            assert(caller == owner, 'Caller is not Owner');
            assert(contract_balance >= amount, 'Insufficient contract balance');
            self.balance.entry(contract).write(contract_balance - amount);
            self.balance.entry(caller).write(callers_balance + amount);
            true
        }
        fn transfer(ref self: ContractState, address: ContractAddress, amount: u64) -> bool {
            let caller = get_caller_address();
            assert(self.balance.entry(caller).read() >= amount, 'Insufficient transfer balance');
            self.balance.entry(caller).write(self.balance.entry(caller).read() - amount);
            self.balance.entry(address).write(self.balance.entry(address).read() + amount);
            true
        }
        fn allowance(
            self: @ContractState, sender: ContractAddress, receiver: ContractAddress,
        ) -> u64 {
            self.allowances.entry((sender, receiver)).read()
        }
        fn approve(ref self: ContractState, address: ContractAddress, amount: u64) -> bool {
            let caller = get_caller_address();
            assert(self.balance.entry(caller).read() >= amount, 'Insufficient approve balance');
            let prev_allowance = self.allowances.entry((caller, address)).read();
            self.allowances.entry((caller, address)).write(prev_allowance + amount);
            true
        }
        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            receiver: ContractAddress,
            amount: u64,
        ) -> bool {
            let contract = get_contract_address();
            assert(
                self.allowances.entry((sender, contract)).read() >= amount,
                'Insufficient allowance',
            );
            assert(self.balance.entry(sender).read() >= amount, 'Insufficient transferfrom bal');
            self.allowances.entry((sender,contract)).write(self.allowances.entry((sender, contract)).read() - amount);
            self.balance.entry(sender).write(self.balance.entry(sender).read() - amount);
            self.balance.entry(receiver).write(self.balance.entry(receiver).read() + amount);
            true
        }
    }
}
