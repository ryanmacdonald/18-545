



module scene_int(input shader_to_sint_t ray_in,
		 input logic v0, v1, v2,
		 input float_t xmin, xmax,
		 input float_t ymin, ymax,
		 input float_t zmin, zmax,
		 input logic tf_ds_stall, ssf_ds_stall, ssh_ds_stall,
		 input logic us_valid,
		 input clk, rst, 
		 output tarb_t tf_ray_out,
		 output sint_to_ss_t ssf_ray_out,
	         output sint_to_shader_t ssh_ray_out,
		 output logic us_stall, tf_ds_valid, ssf_ds_valid, ssh_ds_valid);

	float_t tmin_scene, tmax_scene;
	
	shader_to_sint_t ray;
	ff_ar_en #($bits(shader_to_sint_t),0) rr(.q(ray),.d(ray_in),.en(us_valid),.clk,.rst);

	
	logic isShadow, miss;
	scene_int_pl pl(.ray(ray),.v0(v0),.v1(v1),.v2(v2),
			.xmin(xmin),.xmax(xmax),
			.ymin(ymin),.ymax(ymax),
			.zmin(zmin),.zmax(zmax),
			.isShadow(isShadow), .clk, .rst,
			.tmin_scene(tmin_scene),.tmax_scene(tmax_scene),
			.miss(miss));

	logic ds_valid, ds_stall;
	logic[$bits(rayID_t):0] us_data, ds_data;
	logic[5:0] num_left_in_fifo;
	assign us_data = {ray_in.rayID,ray_in.is_shadow};
	assign isShadow = ds_data[0];
	pipe_valid_stall #(.WIDTH($bits(rayID_t)+1),.DEPTH(17)) pvs
			     (.clk,.rst,.us_valid(us_valid),.us_data(us_data),.us_stall,
			      .ds_valid(ds_valid),.ds_data(ds_data),.ds_stall(ds_stall),
			      .num_left_in_fifo(num_left_in_fifo));

	/* TARB FIFO */	

	sint_entry_t tf_data_in, tf_data_out;
	logic tf_we, tf_re, tf_full, tf_empty;
	logic[5:0] tf_num_left_in_fifo;
	assign tf_we = ds_valid && ~miss;
	assign tf_re = tf_ds_valid && ~tf_ds_stall;
	assign tf_ds_valid = ~tf_empty;

	// fifo data_in assigns
	assign tf_data_in.rayID = ds_data[19:1];
	assign tf_data_in.tmin = tmin_scene;
	assign tf_data_in.tmax = tmax_scene;
	assign tf_data_in.is_shadow = isShadow;
	assign tf_data_in.miss = miss;
	
	// fifo data_out assigns
	assign tf_ray_out.ray_info.ss_wptr = 'h0;
	assign tf_ray_out.ray_info.ss_num = 'h0;
	assign tf_ray_out.ray_info.is_shadow = tf_data_out.is_shadow;
	assign tf_ray_out.ray_info.rayID = tf_data_out.rayID;
	assign tf_ray_out.nodeID = 'h0;
	assign tf_ray_out.restnode_search = 1'b1;
	assign tf_ray_out.t_max = tf_data_out.tmax;
	assign tf_ray_out.t_min = tf_data_out.tmin;
	fifo #(.WIDTH($bits(sint_entry_t)),.DEPTH(18))
	     tf(.clk,.rst,.data_in(tf_data_in),.we(tf_we),.re(tf_re),
		.full(tf_full),.exists_in_fifo(),.empty(tf_empty),.data_out(tf_data_out),
		.num_left_in_fifo(tf_num_left_in_fifo));		


	/* SS FIFO */
	

	sint_to_ss_t ssf_data_in, ssf_data_out;
	logic ssf_we, ssf_re, ssf_full, ssf_empty;
	logic[5:0] ssf_num_left_in_fifo;
	assign ssf_we = ds_valid && ~miss; 
	assign ssf_re = ssf_ds_valid && ~ssf_ds_stall;
	assign ssf_ds_valid = ~ssf_empty;

	// SS fifo data_in assigns
	assign ssf_data_in.rayID = ds_data[19:1]; 
	assign ssf_data_in.t_max_scene = tmax_scene;

	// SS fifo data_out assigns
	assign ssf_ray_out.rayID = ssf_data_out.rayID;
	assign ssf_ray_out.t_max_scene = ssf_data_out.t_max_scene;

	fifo #(.WIDTH($bits(sint_to_ss_t)),.DEPTH(18))
	     ssf(.clk,.rst,.data_in(ssf_data_in),.we(ssf_we),.re(ssf_re),
		 .full(ssf_full),.exists_in_fifo(),
		 .empty(ssf_empty),.data_out(ssf_data_out),
		 .num_left_in_fifo(ssf_num_left_in_fifo));




	/* SHADER FIFO */

	sint_to_shader_t ssh_data_in, ssh_data_out;
	logic ssh_we, ssh_re, ssh_full, ssh_empty;
	logic[5:0] ssh_num_left_in_fifo;
	assign ssh_we = ds_valid && miss;
	assign ssh_re = ssh_ds_valid && ~ssh_ds_stall;
	assign ssh_ds_valid = ~ssh_empty;

	// Sh fifo data_in assigns
	assign ssh_data_in.rayID = ds_data[19:1];

	// Sh fifo data_out assigns
	assign ssh_ray_out.rayID = ssh_data_out.rayID;

	fifo #(.WIDTH($bits(sint_to_shader_t)),.DEPTH(18))
	     ssh(.clk,.rst,.data_in(ssh_data_in),.we(ssh_we),.re(ssh_re),
		 .full(ssh_full),.exists_in_fifo(),.empty(ssh_empty),
		 .data_out(ssh_data_out),.num_left_in_fifo(ssh_num_left_in_fifo));

	
	// Need to give stall unit the minimum of num_lefts
	minimum3 #(6) min(num_left_in_fifo,ssh_num_left_in_fifo,
			  ssf_num_left_in_fifo,tf_num_left_in_fifo);


endmodule: scene_int

