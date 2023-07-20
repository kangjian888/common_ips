#-------------------------------------------------------------------------------------------------------
comp  : clean comp
#-------------------------------------------------------------------------------------------------------
comp  :
	vcs -f common_ips_filelist.f \
		-timescale=1ns/1ps \
		-full64  -R  +vc  +v2k  -sverilog -debug_access+all -kdb \
		|  tee  comp.log 		
fbeb_sim   :
	vcs -f common_ips_filelist.f fbeb_tb.sv \
		-timescale=1ns/1ps \
		-ntb_opts uvm-1.2\
		-full64  -R  +vc  +v2k  -sverilog -debug_access+all -kdb \
		|  tee  vcs.log 
	verdi -ssf fbeb_tb.fsdb &
#-------------------------------------------------------------------------------------------------------
verdi  :
	verdi  -ssf fbeb_tb.fsdb &
#-------------------------------------------------------------------------------------------------------
clean  :
	 rm  -rf  *~  core  csrc  simv*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd
#-------------------------------------------------------------------------------------------------------
