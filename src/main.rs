#![no_std]
#![no_main]
#![feature(abi_efiapi)]
#[macro_use]
extern crate log;
use uefi::prelude::*;
use uefi_services;

#[entry]
fn efi_main(_handle:Handle,system_table:SystemTable<Boot>)->Status {
    uefi_services::init(&system_table).expect_success("failed to initialize utilities");
    info!("Hello  UEFI");
    loop{}
}
