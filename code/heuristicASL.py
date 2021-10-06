

import os


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes

# Create Keys
#t1w = create_key(
   #'sub-{subject}/{session}/anat/sub-{subject}_{session}_T1w')
# t2w = create_key(
#    'sub-{subject}/{session}/anat/sub-{subject}_{session}_T2w')
# dwi = create_key(
#    'sub-{subject}/{session}/dwi/sub-{subject}_{session}_acq-multiband_dwi')
# #qsm_mag_1= create_key(
#     #'sub-{subject}/ses-{session}/swi/sub-{subject}_ses-{session}_part-mag_echo-1_rec-norm_GRE')
# #qsm_mag_2= create_key(
#     #'sub-{subject}/ses-{session}/swi/sub-{subject}_ses-{session}_part-mag_echo-2_rec-norm_GRE')
# #qsm_mag_3= create_key(
#     #'sub-{subject}/ses-{session}/swi/sub-{subject}_ses-{session}_part-mag_echo-3_rec-norm_GRE')
# #qsm_mag_4= create_key(
#     #'sub-{subject}/ses-{session}/swi/sub-{subject}_ses-{session}_part-mag_echo-4_rec-norm_GRE')
# #qsm_phase_1= create_key(
#     #'sub-{subject}/ses-{session}/swi/sub-{subject}_ses-{session}_part-phase_echo-1_GRE')
# #qsm_phase_2= create_key(
#     #'sub-{subject}/ses-{session}/swi/sub-{subject}_ses-{session}_part-phase_echo-2_GRE')
# #qsm_phase_3= create_key(
#     #'sub-{subject}/ses-{session}/swi/sub-{subject}_ses-{session}_part-phase_echo-3_GRE')
# #qsm_phase_4= create_key(
#     #'sub-{subject}/ses-{session}/swi/sub-{subject}_ses-{session}_part-phase_echo-4_GRE')
# fmap_pa_diff = create_key(
#     'sub-{subject}/ses-{session}/fmap/sub-{subject}_ses-{session}_acq-dMRIdistmap_dir-PA_epi')
# fmap_ap_diff = create_key(
#     'sub-{subject}/ses-{session}/fmap/sub-{subject}_ses-{session}_acq-dMRIdistmap_dir-AP_epi')
# fmap_pa_bold = create_key(
#     'sub-{subject}/ses-{session}/fmap/sub-{subject}_ses-{session}_acq-fMRIdistmap_dir-PA_epi')
# fmap_ap_bold = create_key(
#     'sub-{subject}/ses-{session}/fmap/sub-{subject}_ses-{session}_acq-fMRIdistmap_dir-AP_epi')
# rest_mb = create_key(
#    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_acq-multiband_bold')
# # rest_sb = create_key(
# #    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_acq-singleband_bold')
# # fracback = create_key(
# #    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-fracback_acq-singleband_bold')
# # face = create_key(
# #    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-face_acq-singleband_bold')
# # ABCD_rest = create_key('sub-{subject}/ses-{session}/func/sub-{subject}_ses-{session}_task-restbold_run-{item}_bold')
# # the new runs that have to be curated in separate acquisitions
func_rest_run_1 = create_key(
    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_run-1_echo-{item}_bold')
func_rest_run_2 = create_key(
    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_run-2_echo-{item}_bold')
func_rest_run_3 = create_key(
    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_run-3_echo-{item}_bold')
asl = create_key(
   'sub-{subject}/{session}/perf/sub-{subject}_{session}_asl')
# # asl_dicomref = create_key(
# #    'sub-{subject}/{session}/perf/sub-{subject}_{session}_acq-ref_asl')
m0 = create_key(
   'sub-{subject}/{session}/perf/sub-{subject}_{session}_m0scan')
# mean_perf = create_key(
#    'sub-{subject}/{session}/perf/sub-{subject}_{session}_mean-perfusion')



def infotodict(seqinfo):
    last_run = len(seqinfo)

    info = {func_rest_run_2: [], func_rest_run_3: [], func_rest_run_1: [], m0: [], asl: []}#t2w:[], dwi:[], rest_mb:[],
            # m0:[], func_rest_run_1: [], func_rest_run_2: [],
            #   asl: [],  #qsm_mag_1: [], qsm_mag_2: [], qsm_mag_3: [],
            # #qsm_mag_4: [], qsm_phase_1: [], qsm_phase_2: [], qsm_phase_3: [], qsm_phase_4: [],
            # fmap_pa_diff: [], fmap_ap_diff: [], fmap_ap_bold: [], fmap_pa_bold:[]}

    def get_latest_series(key, s):
    #    if len(info[key]) == 0:
        info[key].append(s.series_id)
    #    else:
    #        info[key] = [s.series_id]

    for s in seqinfo:
        protocol=s.protocol_name.lower()
        series_description=s.series_description.lower()
        # if "t1w" in protocol and "vnav" not in series_description:
        #     get_latest_series(t1w, s)
        # elif "abcd_t1w_mpr_vnav" in protocol and "setter" not in series_description:
        #     get_latest_series(t1w, s)
        # elif "anat_t2w" in protocol and "vnav" not in series_description and "NORM" in  s.image_type:
        #    get_latest_series(t2w, s)
        # elif "abcd_t2w_spc_vnav" in protocol and "setter" not in series_description:
        #     get_latest_series(t2w, s)
        if series_description.endswith("asl"):
             info[asl].append(s.series_id)
        if series_description.endswith("m0"):
             info[m0].append(s.series_id)
        elif "rest" in series_description:
            # if "MB" in s.image_type:
            #     get_latest_series(rest_mb,s)
            # elif "abcd_fmri" in protocol:
            #     info[func_rest_run_1].append(s.series_id)
            if "sbref" not in series_description and "run1" in series_description:
                info[func_rest_run_1].append(s.series_id)
            if "sbref" not in series_description and "run2" in series_description:
                info[func_rest_run_2].append(s.series_id)
            if "sbref" not in series_description and "run3" in series_description:
                info[func_rest_run_3].append(s.series_id)
            # else:
            #     info[func_rest_run_2].append(s.series_id)
        # elif s.series_description.endswith("_ASL"):
        #     get_latest_series(asl, s)
        # elif s.series_description.endswith("_M0"):
        #     get_latest_series(m0, s)

            #if s.dcm_dir_name.endswith('e1.nii.gz'):
                #get_latest_series(qsm_mag_1, s)
            #elif s.dcm_dir_name.endswith('e2.nii.gz'):
                #get_latest_series(qsm_mag_2, s)
            #elif s.dcm_dir_name.endswith('e3.nii.gz'):
                #get_latest_series(qsm_mag_3, s)
            #else:
                #get_latest_series(qsm_mag_4, s)
        #elif "qsm" in protocol and not s.is_derived  and "NORM" not in s.image_type:
            #if s.dcm_dir_name.endswith('e1_ph.nii.gz'):
                #get_latest_series(qsm_phase_1, s)
            #elif s.dcm_dir_name.endswith('e2_ph.nii.gz'):
                #get_latest_series(qsm_phase_2, s)
            #elif s.dcm_dir_name.endswith('e3_ph.nii.gz'):
                #get_latest_series(qsm_phase_3, s)
            #else:
                #get_latest_series(qsm_phase_4, s)
        # elif "distortionmap_pa" in protocol and "DIFFUSION" in s.image_type:
        #     get_latest_series(fmap_pa_diff, s)
        # elif "distortionmap_ap" in protocol and "DIFFUSION" in s.image_type:
        #     get_latest_series(fmap_ap_diff, s)
        # elif s.series_description.endswith("dir-PA_epi") and "DIFFUSION" in s.image_type:
        #     get_latest_series(fmap_pa_diff, s)
        # elif s.series_description.endswith("dir-AP_epi") and "DIFFUSION" in s.image_type:
        #     get_latest_series(fmap_ap_diff, s)
        # elif "distortionmap_pa" in protocol and "DIFFUSION" not in s.image_type:
        #     get_latest_series(fmap_pa_bold, s)
        # elif "distortionmap_ap" in protocol and "DIFFUSION" not in s.image_type:
        #     get_latest_series(fmap_ap_bold, s)
        # elif s.series_description.endswith("dir-PA_epi") and "DIFFUSION" not in s.image_type:
        #     get_latest_series(fmap_pa_bold, s)
        # elif s.series_description.endswith("dir-AP_epi") and "DIFFUSION" not in s.image_type:
        #     get_latest_series(fmap_ap_bold, s)
        # elif "dwi_acq-multishell" in protocol and not s.is_derived:
        #     get_latest_series(dwi, s)
        # elif "abcd_dmri" in protocol and "distortionmap" not in series_description:
        #     get_latest_series(dwi, s)      
        # elif s.patient_id in s.dcm_dir_name:
        #     get_latest_series(asl, s)
        # else:
        #     print("Series not recognized!: ", s.protocol_name, s.dcm_dir_name)


    return info


# intendedfor's
IntendedFor = {
#     fmap_pa_diff: [
#         '{session}/dwi/sub-{subject}_{session}_acq-multiband_dwi.nii.gz'
# #correct
#     ],
#     fmap_ap_diff: [
#         '{session}/dwi/sub-{subject}_{session}_acq-multiband_dwi.nii.gz'
#     ],
#     fmap_ap_bold: [
#         '{session}/func/sub-{subject}_{session}_task-restbold_run-1_bold.nii.gz',
#         '{session}/func/sub-{subject}_{session}_task-restbold_run-2_bold.nii.gz',
#         '{session}/func/sub-{subject}_{session}_task-fracback_acq-singleband_bold.nii.gz'
#     ],
#     fmap_pa_bold: [
#         '{session}/func/sub-{subject}_{session}_task-restbold_run-1_bold.nii.gz',
#         '{session}/func/sub-{subject}_{session}_task-restbold_run-2_bold.nii.gz',
#         '{session}/func/sub-{subject}_{session}_task-fracback_acq-singleband_bold.nii.gz' 
     m0: [
        '{session}/perf/sub-{subject}_{session}_asl.nii.gz',
    ]
}

# #ASLmetadata:

MetadataExtras = {

    asl: {
        "ArterialSpinLabelingType": "PCASL",
        "PostLabelingDelay": 1.8,
        "BackgroundSuppression": False,
        "M0Type": "Separate",
        "PCASLType":"balanced",
        "TotalAcquiredPairs":8,
        "LabelingDuration":"",
        "RepetitionTime":4.25,
        "RepetitionTimePreparation": 4.25,
        "VascularCrushing": False,
        "AcquisitionVoxelSize": [2.5, 2.5, 2.5]    
    },
    m0 : {"AcquisitionVoxelSize": [2.5, 2.5, 2.5],
          "RepetitionTimePreparation": 4.25}
}


def AttachToSession():

    NUM_VOLUMES = 8 
    data = ['label', 'control'] * NUM_VOLUMES
    data = '\n'.join(data)
    data = 'volume_type\n' + data # the data is now a string; perfect!

    output_file = {

      'name': '{subject}/{session}/perf/{subject}_{session}_aslcontext.tsv',
      'data': data,
      'type': 'text/tab-separated-values'
    }

    return output_file


