
// use starknet::ContractAddress;

// #[starknet::interface]
// trait INameRegistry<TContractState> {
//     fn store_name(ref self: TContractState, name: felt252);
//     fn get_name(self: @TContractState, address: ContractAddress) -> felt252;
// }


// #[starknet::contract]
// mod NameRegistry {
//     use starknet::{ContractAddress, get_caller_address};

//     #[storage]
//     struct Storage {
//         names: LegacyMap::<ContractAddress, felt252>,
//         total_names: u128,
//         owner: Person
//     }

//     #[event]
//     #[derive(Drop, starknet::Event)]
//     enum Event {
//         StoredName: StoredName,
//     }

//     #[derive(Drop, starknet::Event)]
//     struct StoredName {
//         #[key]
//         user: ContractAddress,
//         name: felt252
//     }

//     #[derive(Copy, Drop, Serde, starknet::Store)]
//     struct Land {
//         name: felt252,
//         address: ContractAddress
//     }

//     #[constructor]
//     fn constructor(ref self: ContractState, owner: Person) {
//         self.names.write(owner.address, owner.name);
//         self.total_names.write(1);
//         self.owner.write(owner);
//     }

//     #[external(v0)]
//     impl NameRegistry of super::INameRegistry<ContractState> {
//         fn store_name(ref self: ContractState, name: felt252) {
//             let caller = get_caller_address();
//             self._store_name(caller, name);
//         }

//         fn get_name(self: @ContractState, address: ContractAddress) -> felt252 {
//             let name = self.names.read(address);
//             name
//         }
//     }

//     #[generate_trait]
//     impl InternalFunctions of InternalFunctionsTrait {
//         fn _store_name(ref self: ContractState, user: ContractAddress, name: felt252) {
//             let mut total_names = self.total_names.read();
//             self.names.write(user, name);
//             self.total_names.write(total_names + 1);
//             self.emit(StoredName { user: user, name: name });

//         }
//     }

//     fn _get_contract_name() -> felt252 {
//         'Name Registry'
//     }
// }

#![allow(unused)]
fn main() {
use starknet::{StorePacking};
use integer::{u128_safe_divmod, u128_as_non_zero};

#[derive(Drop, Serde)]
struct Sizes {
    tiny: u8,
    small: u32,
    medium: u64,
}

const TWO_POW_8: u128 = 0x100;
const TWO_POW_40: u128 = 0x10000000000;

const MASK_8: u128 = 0xff;
const MASK_32: u128 = 0xffffffff;


impl SizesStorePacking of StorePacking<Sizes, u128> {
    fn pack(value: Sizes) -> u128 {
        value.tiny.into() + (value.small.into() * TWO_POW_8) + (value.medium.into() * TWO_POW_40)
    }

    fn unpack(value: u128) -> Sizes {
        let tiny = value & MASK_8;
        let small = (value / TWO_POW_8) & MASK_32;
        let medium = (value / TWO_POW_40);

        Sizes {
            tiny: tiny.try_into().unwrap(),
            small: small.try_into().unwrap(),
            medium: medium.try_into().unwrap(),
        }
    }
}

#[starknet::contract]
mod SizeFactory {
    use super::Sizes;
    use super::SizesStorePacking; //don't forget to import it!

    #[storage]
    struct Storage {
        remaining_sizes: Sizes
    }

    #[external(v0)]
    fn update_sizes(ref self: ContractState, sizes: Sizes) {
        // This will automatically pack the
        // struct into a single u128
        self.remaining_sizes.write(sizes);
    }


    #[external(v0)]
    fn get_sizes(ref self: ContractState) -> Sizes {
        // this will automatically unpack the
        // packed-representation into the Sizes struct
        self.remaining_sizes.read()
    }
}


}