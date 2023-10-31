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