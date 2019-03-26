(module
  (type $t0 (func))
  (type $t1 (func (result i32)))
  (func $__wasm_call_ctors (type $t0))
  (func $computePrimesWasm (export "computePrimesWasm") (type $t1) (result i32)
    (local $l0 i32) (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32)
    i32.const 1
    set_local $l0
    i32.const 2
    set_local $l1
    loop $L0
      get_local $l0
      set_local $l2
      block $B1
        block $B2
          loop $L3
            get_local $l2
            i32.const 2
            i32.lt_s
            br_if $B2
            get_local $l1
            get_local $l2
            i32.rem_s
            set_local $l3
            get_local $l2
            i32.const -1
            i32.add
            set_local $l2
            get_local $l3
            br_if $L3
          end
          get_local $l0
          i32.const 1
          i32.add
          set_local $l0
          get_local $l1
          i32.const 1
          i32.add
          tee_local $l1
          i32.const 80000
          i32.ne
          br_if $L0
          br $B1
        end
        get_local $l1
        set_local $l4
        get_local $l0
        i32.const 1
        i32.add
        set_local $l0
        get_local $l1
        i32.const 1
        i32.add
        tee_local $l1
        i32.const 80000
        i32.ne
        br_if $L0
      end
    end
    get_local $l4)
  (table $T0 1 1 anyfunc)
  (memory $memory (export "memory") 2)
  (global $g0 (mut i32) (i32.const 66560))
  (global $__heap_base (export "__heap_base") i32 (i32.const 66560))
  (global $__data_end (export "__data_end") i32 (i32.const 1024)))