extern crate deblockator;
extern crate jemallocator;

use deblockator::Deblockator;
use jemallocator::Jemalloc;

mod cases;

#[global_allocator]
static GLOBAL: Deblockator<Jemalloc> = Deblockator::new(Jemalloc);

#[test]
fn test_small_alloc() {
    cases::small_alloc();
}
