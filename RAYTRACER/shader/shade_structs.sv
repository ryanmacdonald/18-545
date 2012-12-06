/* file to hold all the structs that are contained within the shader */


typedef struct packed {
  rayID_t rayID;
  logic is_shadow;
  logic is_miss;
} shadow_or_miss_t ;

typedef struct packed {
  rayID_t rayID;
  vector_t p_int;
  vector_t normal;
  vector_t light;
} scache_to_sendshadow_t;

typedef struct packed {
  rayID_t rayID;

} scache_to_dirpint_t;

typedef struct packed {
  rayID_t rayID;
  float_t color;
} calc_direct_to_BM_t;

typedef struct packed {
  rayID_t rayID;
  vector_t dir;
  vector_t p_int; 
  vector_t normal;
} dirpint_to_sendreflect_t;

typedef struct packed {
  rayID_t rayID;
  triID_t triID;
} triidstate_to_scache;

typedef struct packed{
  rayID_t rayID;
  vector_t p_int;
} sr_pvs_entry_t;


typedef struct packed {
  rayID_t rayID;
  float_t A;
  float_t K;
  float_t C;
  logic is_shadow;
  logic miss;
  vector_t N;
  vector_t p_int;
  vector_t L;
} dirpint_to_calc_direct_t;

typedef struct packed {
  rayID_t rayID;
  float_color_t f_color;
} raydone_t;

typedef struct packed {
  pixelID_t pixelID;
  float_color_t f_color;

} pixstore_to_cc_t;
