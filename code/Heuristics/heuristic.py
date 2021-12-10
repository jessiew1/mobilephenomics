#testing

import os


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes

# Create Keys
t1w = create_key(
   'sub-{subject}/{session}/anat/sub-{subject}_{session}_T1w')
fmap_pa_bold = create_key(
    'sub-{subject}/ses-{session}/fmap/sub-{subject}_ses-{session}_acq-fMRIdistmap_dir-PA_epi')
fmap_ap_bold = create_key(
    'sub-{subject}/ses-{session}/fmap/sub-{subject}_ses-{session}_acq-fMRIdistmap_dir-AP_epi')
rest_mb = create_key(
   'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_acq-multiband_echo-{item}_bold')


def infotodict(seqinfo):
    last_run = len(seqinfo)

    info = {rest_mb:[], t1w:[], fmap_ap_bold:[],fmap_pa_bold:[]}

    def get_latest_series(key, s):
    #    if len(info[key]) == 0:
        info[key].append(s.series_id)
    #    else:
    #        info[key] = [s.series_id]

    for s in seqinfo:
        protocol=s.protocol_name.lower()
        series_description=s.series_description.lower()
        if "ABCD_T1w_MPR_vNav" in series_description and "NORM" in s.image_type:
            get_latest_series(t1w, s)
        if "rest" in series_description:
            if "MB" in s.image_type:
                get_latest_series(rest_mb,s)
        if s.series_description.endswith("_AP"):
            get_latest_series(fmap_ap_bold, s)
        elif s.series_description.endswith("_PA"):
            get_latest_series(fmap_pa_bold, s)

        # else:
        #     print("Series not recognized!: ", s.protocol_name, s.dcm_dir_name)


    return info


# intendedfor's
IntendedFor = {
    fmap_ap_bold: [
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_acq-multiband_echo-{item}_bold'
    ],
    fmap_pa_bold: [
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_acq-multiband_echo-{item}_bold',
    ]
}

# #ASLmetadata:

# MetadataExtras = {

    # asl: {
    #     "ArterialSpinLabelingType": "PCASL",
    #     "PostLabelingDelay": 1.8,
    #     "BackgroundSuppression": False,
    #     "M0Type": "Separate",
    #     "PCASLType":"balanced",
    #     "TotalAcquiredPairs":8,
    #     "LabelingDuration":"",
    #     "RepetitionTime":4.25,
    #     "RepetitionTimePreparation": 4.25,
    #     "VascularCrushing": False,
    #     "AcquisitionVoxelSize": [2.5, 2.5, 2.5]    
    # },
    # m0 : {"AcquisitionVoxelSize": [2.5, 2.5, 2.5],
    #       "RepetitionTimePreparation": 4.25}
# }


# def AttachToSession():

#     NUM_VOLUMES = 8 
#     data = ['label', 'control'] * NUM_VOLUMES
#     data = '\n'.join(data)
#     data = 'volume_type\n' + data # the data is now a string; perfect!

#     output_file = {

#       'name': '{subject}/{session}/perf/{subject}_{session}_aslcontext.tsv',
#       'data': data,
#       'type': 'text/tab-separated-values'
#     }

#     return output_file


