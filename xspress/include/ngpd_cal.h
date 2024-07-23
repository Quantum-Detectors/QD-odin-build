
#ifndef _NGPD_CAL_H
#define _NGPD_CAL_H

/**
@defgroup NGPD_CAL_MACROS 		Macros relating to the ngpd auto calibration software
@{
*/
#define NGPD_CAL_MAX_PHASES 3
#define NGPD_CAL_MAX_DIFFS (16)

#define NGPD_CAL_DIFF_TRIG 	0
#define NGPD_CAL_DIFF_VARY_SEP 100

#define NGPD_CAL_NUM_THRES 	1
#define NGPD_CAL_NUM_SIGMA	1

/**
@}
 * @ingroup calibration
 @{
*/
/** Data structure of settings to control ngpd_cal_measure_trigger and internal data */
typedef struct 
{
	int path;				//!< Path number of the system, set by ngdp_cal_measure_trigger_default. Should not be changed.
	int cn;					//!< For use with playback testing with da.server.
	int num_chan;			//!< Number of channels, set by ngdp_cal_measure_trigger_default. Available for information but should not be changed.
	int first_chan;			//!< First channel to process set to 0 by default, but can be changed.
	int last_chan;			//!< Last channel to process set to num_chan-1 by default, but can be changed.
	char persist_name[NGPD_MAX_MODNAME+2];	//!< Root Module name to store persistence views of data. Must be set if persistence mode is required. Also set do_persist.
											//!< The suffix _phase<phase>_<chan_num> will be appended to the root name to name the module for each phase and channel.
	char ave_name[NGPD_MAX_MODNAME+2];		//!< Root module name to store averaged data. This is required for the post processing options.
											//!< The suffix _phase<phase>_<chan_num> will be appended to the root name to name the module for each phase and channel.
	char xtk_name[NGPD_MAX_MODNAME+2];		//!< Root module name to store averaged data. This is required for the post processing options.
											//!< The suffix _phase<phase>_<chan_num> will be appended to the root name to name the module for each phase and channel.
	int do_persist;			//!< Set to enable production of persistence mode data.
	int do_ave;				//!< Set to enable production of averaged data
	int do_xtk;				//!< Set to enable production of averaged Crosstalk data
	int use_measure;		//!< Set collect data from the data supplied to the measure block of the VHDL after the baseline and optionally tail subtraction. {@link NGPD_CAL_USE_MEASURE_MACROS}
	int pre;				//!< Number if samples to store before the event trigger. Default 25 but can be changed.
	int post;				//!< Numbre of samples to stire after the event trigger. Default 170, but can be changed.
	int no_clear;			//!< Set to disable clear of the data modules, so new data is accumulated on top of the existing data.
	int num_pass;			//!< Number of passes running the system and accumulating data. Default 1, but can be increased to improve statistics, particularly if working at low count rates.
	int col_sat;			//!< Adjust the appearance of the histogram displays.
	int persist_num_y;		//!< Height in bins of the 2-d data modules used for persistence display, default 1200
	int auto_neutron_height;	//!< Process data in 2 phases. For the first phase locate the neutron peak height from the MCA ans use this to set the min_hgt_neutron and max_hgt_neutron automatically
								//!< for a second phase which separates neutrons and gammas.
	double *min_event;		//!< Pointer to array of minimum event height to be included in average, set on a per channel basis. 
							//!< The array a malloced by ngdp_cal_measure_trigger_default and initialised to -1 to disable check. The contents of the array can be set by user code.
	double *max_event;		//!< Pointer to array of maximum event height to include in average, set on a per channel basis.
	double *min_hgt_neutron;//!< Pointer  Pointer to array of minimum event height to be classified as a neutron, set on a per channel basis.
							//!< The array a malloced by ngdp_cal_measure_trigger_default and initialised to -1 to disable separating neutrons and gammas. 
							//!< The contents of the array can be set by user code.
							//!< Alternately the auto_neutron_height feature can be used to set this automatically.
	double *max_hgt_neutron;//!< Pointer  Pointer to array of minimum event height to be classified as a neutron, set on a per channel basis.
	int num_phase;			//!< Number of phaes of processing, Default 1, but increased to 2 if auto_neutron_height is used.
	int disable_multi_thread;	//!< For multi-card systems the library will launch a thread per card. Set this to disable multi-threading.
	char *playback;			//!< Pointer to a string storing a da.server ngpd playback load command to allow automatic testing with multiple passes of playback data.
	int	(*user_service)(int, char*, int, FILE *, FILE *); //!< Pointer to da.server user_service function (or equivalent) to allow plackback option to be used.	
	
	int thread_index;		//!< Internal use.
	int num_cards;
	MOD_IMAGE3D *ave_mod[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	mh_com *ave_head[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	MOD_IMAGE3D *persist_mod[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	mh_com *persist_head[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	MOD_IMAGE *num_ave_mod[NGPD_CAL_MAX_PHASES];
	mh_com *num_ave_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE3D *mca_mod[NGPD_CAL_MAX_PHASES];
	mh_com *mca_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE *ave_by_width_mod[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	mh_com *ave_by_width_head[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	MOD_IMAGE *num_ave_by_width_mod[NGPD_CAL_MAX_PHASES];
	mh_com *num_ave_by_width_head[NGPD_CAL_MAX_PHASES];
	NGPDScopeModule * scope_mod;
	MOD_IMAGE3D *xtk_all_mod[NGPD_CAL_MAX_PHASES];
	mh_com *xtk_all_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE3D *xtk_neutron_mod[NGPD_CAL_MAX_PHASES];
	mh_com *xtk_neutron_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE3D *xtk_gamma_mod[NGPD_CAL_MAX_PHASES];
	mh_com *xtk_gamma_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE3D *num_ave_xtk_mod[NGPD_CAL_MAX_PHASES];
	mh_com *num_ave_xtk_head[NGPD_CAL_MAX_PHASES];
	int extra_pre, extra_post;
	int trig_min_otd, trig_max_otd;
	int phase; 
	double scale_sigma;
	int first_card, last_card;
	int chans_per_card;
	double mca_scale;
	int max_width, max_fine_time;
	int first_stream, last_stream,  trig_offset, wide_offset_a, wide_offset_b, neutron_offset;
	char variable_width_mode[NGPD_MAX_CHANS];
	int need_upper;
} NGPDMeasureTrigger;

/** Data structure of settings to control ngpd_cal_tail_subtract */
typedef struct {
	int path;				//!< Path number of the system, set by ngdp_cal_measure_trigger_default. Should not be changed.
	int num_chan;			//!< Number of channels, set by ngdp_cal_measure_trigger_default. Available for information but should not be changed.
	int first_chan;			//!< First channel to process set to 0 by default, but can be changed.
	int last_chan;			//!< Last channel to process set to num_chan-1 by default, but can be changed.
	char *root_ave_name;	//!< root module name for the averaged data from ngpd_cal_measure_trigger with _phase[1|2] appened as appropriate.
	char *root_fname;		//!< Root file name to save tail shapes to file if required.
	int fit_ramp;			//!< For future expansion
	double scale_tail;		//!< Default 1, for firmware debugging only
	int end_offset;			//! Default 0, for debugging only
} NgpdCalTailSubtract;

/** Data structure of settings to control ngpd_cal_adjust_trigger_timing */
typedef struct ngpd_cal_adjust_trigger_timing_t
{
	int path;				//!< Path number of the system, set by ngdp_cal_measure_trigger_default. Should not be changed.
	int num_chan;			//!< Number of channels, set by ngdp_cal_measure_trigger_default. Available for information but should not be changed.
	int first_chan;			//!< First channel to process set to 0 by default, but can be changed.
	int last_chan;			//!< Last channel to process set to num_chan-1 by default, but can be changed.
	char * ave_name;		//!< The root name of teh averages data module from ngpd_cal_measure_trigger() e.g. "ave_phase1". "_<chan_num>" will be appended
	char *res_name;			//!< Module name to store the results in.
	double sig_first_thres[NGPD_NUM_STRETCHED_TRIG];	//!< Threshold as fraction 0 ... 1.0 of the maximum of the analogue pulse shape to define the start of the pulse.
														//!< Note that the thres for the two wide signal a nd b can be different if required. Default 0.005
	double sig_last_thres[NGPD_NUM_STRETCHED_TRIG];		//!< Threshold as fraction 0 ... 1.0 of the maximum of the analogue pulse shape to define the end of the pulse.
	double wide_first_thres[NGPD_NUM_STRETCHED_TRIG];	//!< Threshold 0 ... 1.0 the determine the start of the 2 wide trigger signals
	double wide_last_thres[NGPD_NUM_STRETCHED_TRIG];	//!< Threshold 0 ... 1.0 the determine the end of the 2 wide trigger signals
	int wide_first_offset[NGPD_NUM_STRETCHED_TRIG];		//!< Required offset in samples from the start of the analogue signal to the digital signal
	int wide_last_offset[NGPD_NUM_STRETCHED_TRIG];		//!< Required offset in samples from the end of the analogue signal to the digital signal
	int no_clear;										//!< Do not clear results data module to allow results from multiple calls on different channel range to splice together.
	int wide_a_pulse;									//!< Force wide_a signal to be a single clock cycle wide marker pulse
	int fit_ramp;										//!< For future expansion
	int just_check;										//!< Process data and print changes, but do to change trigger settings.
} NgpdCalAdjustTiming;

/** Data structure of settings to control ngpd_cal_hist_diffs */
typedef struct ngpd_cal_hist_diff_t
{
	int path;				//!< Path number of the system, set by ngdp_cal_measure_trigger_default. Should not be changed.
	int cn;					//!< For use with playback testing with da.server.
	int num_chan;			//!< Number of channels, set by ngdp_cal_measure_trigger_default. Available for information but should not be changed.
	int first_chan;			//!< First channel to process set to 0 by default, but can be changed.
	int last_chan;			//!< Last channel to process set to num_chan-1 by default, but can be changed.
	enum {Normal, VarySep } mode;	//!< Normal mode tests the setting for the trigger, VarySep tests NGPD_CAL_MAX_DIFFS different separations in one run.
	int chunk_size;			//!< length of chunk of data to process in one go, default 1024 samples.
	char persist_name[NGPD_MAX_MODNAME+2];	//!< Module name to enable persistence mode.
	int diff_sep[NGPD_CAL_MAX_DIFFS];		//!< Separation in samples between the values differenced usually read from firmware.
	int persist_errant;		//!< Use with persistence mode to record events with larger differences
	int errant_thres[NGPD_CAL_MAX_DIFFS];	//<! Threshold for an difference to be considered errant and record in errant persistence mode
	int no_clear;			//!< Usually the data modules are cleared before starting, but setting no_clear prevent this, allowing data from multiple runs can be accumulated, 
							//!< or runs over different channels can be spliced together.
	int num_pass;			//!< Number of passes, default 1
	int persist_num_y;		//!< Height of persistence data modules.
	int col_sat;			//!< Adjust the colouring on persistence mode
	char *playback;			//!< Point to string of a playback command to pass to (user_service) to load different playback files for each pass. Used within da.server
	int hist_num_x;			//!< Width of the differences histogram, default 1024.
	int diff_trig_from_hw;	//!< Default 1 takes difference separation from the current firmware settings, 0 => caller will supply diff_sep.
	int	(*user_service)(int, char*, int, FILE *, FILE *);	//!< Function to process the playback command, particularly with da.server
} NgpdCalHistDiffs;

/** Data structure of settings to control ngpd_cal_adjust_trigger_thresholds */
typedef struct ngpd_cal_adjust_trigger_thresholds_t 
{
	int path;				//!< Path number of the system, set by ngdp_cal_measure_trigger_default. Should not be changed.
	int num_chan;			//!< Number of channels, set by ngdp_cal_measure_trigger_default. Available for information but should not be changed.
	int first_chan;			//!< First channel to process set to 0 by default, but can be changed.
	int last_chan;			//!< Last channel to process set to num_chan-1 by default, but can be changed.
	enum {Unchanged, ScaleSigma, Fraction } 
		thres_type[NGPD_CAL_NUM_THRES]; //!< How to set threshold. Note this is an array to allow for future expansion if the trigger engine 
							//!< needs more than one threshold. Currently only element thres_type[NGPD_CAL_DIFF_TRIG] is used.
							//!< Threshold can Unchanged by this call (for future expansion), set by Scaling sigma or to trigger on a specified (small) fraction of samples.
	double thres_val[NGPD_CAL_NUM_THRES]; 	//!< Value to use when calculating the threshold. For ScaleSigma it is a scaling faction, typically 5
											//!< For Faction mode it would be a small number e.g. 0.0001
	int first_thres;		//!< For future expansion, would allow only specified threshold to be changed if there were more than one. Currently must be NGPD_CAL_DIFF_TRIG
	int last_thres;			//!< For future expansion, would allow only specified threshold to be changed if there were more than one. Currently must be NGPD_CAL_DIFF_TRIG
	int no_clear;			//!< Do not clear output data module. Allows results from several calls to this function to be spliced together.
} NgpdCalAdjustTrigThres;

/** Data structure of settings to control ngpd_cal_measure_trigger and internal data */
typedef struct 
{
	int path;				//!< Path number of the system, set by ngdp_cal_measure_trigger_default. Should not be changed.
	int cn;					//!< For use with playback testing with da.server.
	int num_chan;			//!< Number of channels, set by ngdp_cal_measure_trigger_default. Available for information but should not be changed.
	int first_chan;			//!< First channel to process set to 0 by default, but can be changed.
	int last_chan;			//!< Last channel to process set to num_chan-1 by default, but can be changed.
	char persist_name[NGPD_MAX_MODNAME+2];	//!< Root Module name to store persistence views of data. Must be set if persistence mode is required. Also set do_persist.
											//!< The suffix _phase<phase>_<chan_num> will be appended to the root name to name the module for each phase and channel.
	char ave_name[NGPD_MAX_MODNAME+2];		//!< Root module name to store averaged data. This is required for the post processing options.
											//!< The suffix _phase<phase>_<chan_num> will be appended to the root name to name the module for each phase and channel.
	char xtk_name[NGPD_MAX_MODNAME+2];		//!< Root module name to store averaged data. This is required for the post processing options.
											//!< The suffix _phase<phase>_<chan_num> will be appended to the root name to name the module for each phase and channel.
	int do_persist;			//!< Set to enable production of persistence mode data.
	int do_ave;				//!< Set to enable production of averaged data
	int do_xtk;				//!< Set to enable production of averaged Crosstalk data
	int use_measure;		//!< Set collect data from the data supplied to the measure block of the VHDL after the baseline and optionally tail subtraction. {@link NGPD_CAL_USE_MEASURE_MACROS}
	int pre;				//!< Number if samples to store before the event trigger. Default 25 but can be changed.
	int post;				//!< Numbre of samples to stire after the event trigger. Default 170, but can be changed.
	int no_clear;			//!< Set to disable clear of the data modules, so new data is accumulated on top of the existing data.
	int num_pass;			//!< Number of passes running the system and accumulating data. Default 1, but can be increased to improve statistics, particularly if working at low count rates.
	int col_sat;			//!< Adjust the appearance of the histogram displays.
	int persist_num_y;		//!< Height in bins of the 2-d data modules used for persistence display, default 1200
	int auto_neutron_height;	//!< Process data in 2 phases. For the first phase locate the neutron peak height from the MCA ans use this to set the min_hgt_neutron and max_hgt_neutron automatically
								//!< for a second phase which separates neutrons and gammas.
	double *min_event;		//!< Pointer to array of minimum event height to be included in average, set on a per channel basis. 
							//!< The array a malloced by ngdp_cal_measure_trigger_default and initialised to -1 to disable check. The contents of the array can be set by user code.
	double *max_event;		//!< Pointer to array of maximum event height to include in average, set on a per channel basis.
	double *min_hgt_neutron;//!< Pointer  Pointer to array of minimum event height to be classified as a neutron, set on a per channel basis.
							//!< The array a malloced by ngdp_cal_measure_trigger_default and initialised to -1 to disable separating neutrons and gammas. 
							//!< The contents of the array can be set by user code.
							//!< Alternately the auto_neutron_height feature can be used to set this automatically.
	double *max_hgt_neutron;//!< Pointer  Pointer to array of minimum event height to be classified as a neutron, set on a per channel basis.
	int num_phase;			//!< Number of phaes of processing, Default 1, but increased to 2 if auto_neutron_height is used.
	int disable_multi_thread;	//!< For multi-card systems the library will launch a thread per card. Set this to disable multi-threading.
	char *playback;			//!< Pointer to a string storing a da.server ngpd playback load command to allow automatic testing with multiple passes of playback data.
	int	(*user_service)(int, char*, int, FILE *, FILE *); //!< Pointer to da.server user_service function (or equivalent) to allow plackback option to be used.	
	
	int thread_index;		//!< Internal use.
	int num_cards;
	MOD_IMAGE3D *ave_mod[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	mh_com *ave_head[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	MOD_IMAGE3D *persist_mod[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	mh_com *persist_head[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	MOD_IMAGE *num_ave_mod[NGPD_CAL_MAX_PHASES];
	mh_com *num_ave_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE3D *mca_mod[NGPD_CAL_MAX_PHASES];
	mh_com *mca_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE *ave_by_width_mod[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	mh_com *ave_by_width_head[NGPD_CAL_MAX_PHASES][NGPD_MAX_CHANS];
	MOD_IMAGE *num_ave_by_width_mod[NGPD_CAL_MAX_PHASES];
	mh_com *num_ave_by_width_head[NGPD_CAL_MAX_PHASES];
	NGPDScopeModule * scope_mod;
	MOD_IMAGE3D *xtk_all_mod[NGPD_CAL_MAX_PHASES];
	mh_com *xtk_all_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE3D *xtk_neutron_mod[NGPD_CAL_MAX_PHASES];
	mh_com *xtk_neutron_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE3D *xtk_gamma_mod[NGPD_CAL_MAX_PHASES];
	mh_com *xtk_gamma_head[NGPD_CAL_MAX_PHASES];
	MOD_IMAGE3D *num_ave_xtk_mod[NGPD_CAL_MAX_PHASES];
	mh_com *num_ave_xtk_head[NGPD_CAL_MAX_PHASES];
	int extra_pre, extra_post;
	int trig_min_otd, trig_max_otd;
	int phase; 
	double scale_sigma;
	int first_card, last_card;
	int chans_per_card;
	double mca_scale;
	int max_width, max_fine_time;
	int first_stream, last_stream,  trig_offset, wide_offset_a, wide_offset_b, neutron_offset;
	char variable_width_mode[NGPD_MAX_CHANS];
	int need_upper;
} NGPDMeasureCrosstalk;

/**
@}
*/


char * ngpd_cal_get_error_message();
int ngpd_cal_setup_all_ana(int path,  int card, int sync_boxes, int src);
int ngpd_cal_setup_trig_or_measure(int path,  int card, int use_measure, int do_upper, int *first_stream, int *last_stream,  int *trig_offset, int *wide_a_offset, int *wide_b_offset, int *neutron_offset, int sync_boxes, int *need_upper);
int ngpd_cal_setup_trig_or_measure_get_chan(int path, int use_measure, int do_upper, int stream);
int ngpd_cal_setup_all_chan(int path,  int card, int scope_src, int *first_stream, int *last_stream,  int *trig_offset, int *wide_a_offset, int *wide_b_offset, int *neutron_offset, int sync_boxes);
int ngpd_cal_setup_all_chan_get_chan(int path, int scope_src, int stream);

int ngpd_cal_offsets(int path,  void (*nprintf)(void *msg_data, char *, ...), void *msg_data, int first_chan, int last_chan, double target, int num_pass, int adjust_only, char *save_fname);
int ngpd_cal_measure_trigger_validate(NGPDMeasureTrigger *set);

void ngdp_cal_measure_trigger_delete(NGPDMeasureTrigger *set);
NGPDMeasureTrigger *ngdp_cal_measure_trigger_default(int path);
int ngpd_cal_measure_trigger(NGPDMeasureTrigger *set);
NgpdCalTailSubtract *ngpd_cal_tail_subtract_default(int path, char *root_ave_name, char *root_fname);
void ngpd_cal_tail_subtract_delete(NgpdCalTailSubtract *set);
int ngpd_cal_tail_subtract (NgpdCalTailSubtract *set);
NgpdCalAdjustTiming * ngpd_cal_adjust_trigger_timing_default (int path, char *ave_name, char *res_name);
void ngpd_cal_adjust_trigger_timing_delete(NgpdCalAdjustTiming *set);
int ngpd_cal_adjust_trigger_timing(NgpdCalAdjustTiming *set);
void ngpd_cal_accumulate_ave(int16_t * ana_ptr, u_int16_t * dig_ptr,  int offset, MOD_IMAGE3D *mod, int mod_t, int pre, int post, double baseline, int ana_inc, int dig_inc, u_int16_t trig_mask, u_int16_t wide_mask_a, u_int16_t wide_mask_b);
void ngpd_cal_accumulate_persist(int16_t * ana_ptr, u_int16_t *dig_ptr,  int offset, MOD_IMAGE3D *mod, int mod_t, int pre, int post, int base_line, int divide, int cap_len, u_int16_t bmask0, u_int16_t bmask1, u_int16_t bmask2, int ana_inc, int dig_inc);

NgpdCalHistDiffs * ngpd_cal_hist_diffs_default(int path);
void ngpd_cal_hist_diffs_delete(NgpdCalHistDiffs *set);
int ngpd_cal_hist_diffs (NgpdCalHistDiffs *set);
int ngpd_cal_measure_diff_hist (int path, int diff_num, double fraction, int decades, int num_settings, int mask_0_diff);

NgpdCalAdjustTrigThres * ngpd_cal_adjust_trigger_thresholds_default(int path);
void ngpd_cal_adjust_trigger_thresholds_delete(NgpdCalAdjustTrigThres *set);
int ngpd_cal_adjust_trigger_thresholds_validate(NgpdCalAdjustTrigThres *set);
int ngpd_cal_adjust_trigger_thresholds(NgpdCalAdjustTrigThres *set);

extern int (*ngpd_cal_test_quit)(void);

/**
@defgroup NGPD_CAL_SHAPE_MOD_MACROS Macros to describe the layout of the data module created by  {@link ngpd_cal_measure_trigger}
@ingroup NGPD_CAL_MACROS
@{
*/
#define NGPD_CAL_MOD_ROW_SIG 		0		//!< Module row=y=0 : Averaged signal shape
#define NGPD_CAL_MOD_ROW_TRIG 		1		//!< Module row=y=1 : Averaged position of trigger signal
#define NGPD_CAL_MOD_ROW_WIDE_A 	2		//!< Module row=y=2 : Averaged position and width of wide_a signal
#define NGPD_CAL_MOD_ROW_WIDE_B 	3		//!< Module row=y=3 : Averaged position and width of wide_a signal
#define NGPD_CAL_MOD_ROW_FIT		4		//!< Module row=y=3 : For future expansion
#define NGPD_CAL_MOD_ROW_CORRECTED	5		//!< Module row=y=3 : For future expansion
#define NGPD_CAL_MOD_ROW_DIFF1		6		//!< Module row=y=3 : For future expansion. Proposed to calculate first differential to assess under/overshoot.
     
#define NGPD_CAL_MOD_NUM_ROW 		7		//!< Total number of rows in data module

#define NGPD_CAL_MOD_T_ALL 			0		//!< Module t=0 stores all events (or sum or neytron + gamma)
#define NGPD_CAL_MOD_T_NEUTRON 		1		//!< Module t=1 stores	neutrons, when using min_hgt_neutron/max_hgt_neutron to separate neutrons and gammas 
#define NGPD_CAL_MOD_T_GAMMA 		2		//!< Module t=2 stores  gammas (strictly others) when using min_hgt_neutron/max_hgt_neutron to separate neutrons and gammas 

#define NGPD_CAL_MOD_NUM_T 			3		//!< Total number of planes in data module
/**
@}
*/
/**
@defgroup NGPD_CAL_HIST_MOD_MACROS Layout of the data module created by  {@link ngpd_cal_measure_diff_hist} from {@link ngpd_cal_hist_diffs()}
@ingroup NGPD_CAL_MACROS
@{
*/
#define NGPD_CAL_MAX_DECADES 3			//!< ngpd_cal_measure_diff_hist forms the cumulative sum and finds the threshold to from the fraction, fraction/10, fraction/100 of samples.
#define NGPD_CAL_HIST_RES_MEAN    0 	//!< Module row=y=0: Stores the mean of the histogram. Usually near 0 is the noise is symmetric.
#define NGPD_CAL_HIST_RES_STDEV   1		//!< Module row=y=1: Stores the standard deviation of the noise.
#define NGPD_CAL_HIST_RES_FRAC1   2		//!< Module row=y=2: Stores the threshold to trigger on the specified fraction of samples
#define NGPD_CAL_HIST_RES_FRAC10  3		//!< Module row=y=3: Stores the threshold to trigger on the specified fraction/10 of samples
#define NGPD_CAL_HIST_RES_FRAC100 4		//!< Module row=y=4: Stores the threshold to trigger on the specified fraction/100 of samples
/**
@}
*/
#define NGPD_CAL_THRES_DIFF_TRIG   		0
#define NGPD_CAL_THRES_DIFF_TRIG_SIGMA	1
#define NGPD_CAL_THRES_NUM_ROWS			2

/**
@defgroup NGPD_CAL_USE_MEASURE_MACROS Macros to control the data captured by {@link ngpd_cal_setup_trig_or_measure}
@ingroup NGPD_CAL_MACROS
@{
*/
#define NGPD_CAL_USE_MEASURE_NONE 		0	//!< {@link ngpd_cal_setup_trig_or_measure} takes data from Diff Trigger output
#define NGPD_CAL_USE_MEASURE_RAW 		1	//!< {@link ngpd_cal_setup_trig_or_measure} takes raw data from pulse measure block
#define NGPD_CAL_USE_MEASURE_CORRECTED 	2	//!< {@link ngpd_cal_setup_trig_or_measure} takes tail subtracted data from pulse measrue block
/**
@}
*/


#endif /* _NGPD_CAL_H */
