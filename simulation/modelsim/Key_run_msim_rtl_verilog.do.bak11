transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/20112/Desktop/Key {C:/Users/20112/Desktop/Key/InvCipher128.v}
vlog -vlog01compat -work work +incdir+C:/Users/20112/Desktop/Key {C:/Users/20112/Desktop/Key/cipher.v}
vlog -vlog01compat -work work +incdir+C:/Users/20112/Desktop/Key {C:/Users/20112/Desktop/Key/cipher256.v}
vlog -vlog01compat -work work +incdir+C:/Users/20112/Desktop/Key {C:/Users/20112/Desktop/Key/cipher192.v}
vlog -vlog01compat -work work +incdir+C:/Users/20112/Desktop/Key {C:/Users/20112/Desktop/Key/InvCipher256.v}
vlog -vlog01compat -work work +incdir+C:/Users/20112/Desktop/Key {C:/Users/20112/Desktop/Key/InvCipher192.v}
vlog -vlog01compat -work work +incdir+C:/Users/20112/Desktop/Key {C:/Users/20112/Desktop/Key/wrapper.v}

vlog -vlog01compat -work work +incdir+C:/Users/20112/Desktop/Key {C:/Users/20112/Desktop/Key/wrapper_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  wrapper_tb

add wave *
view structure
view signals
run -all
