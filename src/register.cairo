use starknet::{ContractAddress};
//The interface for the functions we would be implementing
#[starknet::interface]
pub trait IRegisterTrait<TContractState> {
    fn register(ref self: TContractState, name: felt252, address: ContractAddress) -> bool;
    fn get(self: @TContractState, id: u32) -> Register::RegisterStruct;
    fn get_all(self: @TContractState) -> Array<Register::RegisterStruct>;
}

//Initializing the smart contract
#[starknet::contract]
pub mod Register {
    use starknet::{ContractAddress};
    use core::starknet::storage::{
        Map, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
    };

    //Initializing the storage
    #[storage]
    struct Storage {
        list: Map<u32, RegisterStruct>,
        id: u32,
    }

    #[derive(Drop, Serde, starknet::Store)]
    pub struct RegisterStruct {
        _name: felt252,
        _address: ContractAddress,
        _id: u32,
    }

    #[abi(embed_v0)]
    impl RegisterImpl of super::IRegisterTrait<ContractState> {
        fn register(ref self: ContractState, name: felt252, address: ContractAddress) -> bool {
            let id_reg: u32 = self.id.read() + 1;
            let mut registered = RegisterStruct { _name: name, _address: address, _id: id_reg };

            self.list.entry(id_reg).write(registered);
            self.id.write(id_reg);

            true
        }

        fn get(self: @ContractState, id: u32) -> RegisterStruct {
            self.list.entry(id).read()
        }

        fn get_all(self: @ContractState) -> Array<RegisterStruct> {
            let mut reg_array: Array<RegisterStruct> = ArrayTrait::new();
            let mut counter = 0;
            let total_id = self.id.read();

            while counter <= total_id {
                let reglist = self.list.entry(counter).read();
                reg_array.append(reglist);
            };

            counter += 1;
            reg_array
        }
    }
}
