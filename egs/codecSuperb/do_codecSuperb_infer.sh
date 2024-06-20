#!/usr/bin/env bash

# At least one gpu is required.
# Please set --gpu_devices to the gpu you want to use. --gpu_devices "0,1,2,3" mean to use 4 gpus

bit_width=8000

model_dir=models/16k/
model_name=8epoch.pth
sample_rates=(16000 44100 48000)

#
#model_dir=models/44k/
#model_name=11epoch.pth
#sample_rates=(44100)

#model_dir=models/48k/
#model_name=25epoch.pth
#sample_rates=(48000)

use_scale=true

ref_audio_dir=/ws/data
syn_audio_dir=/ws/recon_data

#sample_rates=(16000 44100 48000)
for file_sampling_rate in ${sample_rates[@]}; do
    # encode wav
    input_wav_scp=/ws/test_wavscp/${file_sampling_rate}_wav.scp
    # decode codec
    rm -rf outputs/codecs
    echo "file_sampling_rate: ${file_sampling_rate}"
    # get sampling_rate from model_dir/config.yaml
    sample_frequency=$(grep "^sampling_rate:" ${model_dir}/config.yaml | awk '{print $2}')
    echo "sample_frequency: ${sample_frequency}"
    # if file_sampling_rate is not equal to sample_frequency, then resample the wav to sample_frequency
    # and upsample the generated wav to file_sampling_rate
    bash encoding_decoding.sh --stage 1 --batch_size 16 --num_workers 4 --gpu_devices "0"   \
        --model_dir ${model_dir} --bit_width $bit_width \
        --model_name ${model_name} \
        --wav_scp $input_wav_scp  \
        --out_dir outputs/codecs \
        --file_sampling_rate $file_sampling_rate \
        --sample_frequency $sample_frequency \
        --use_scale $use_scale
    
    # decode wav
    rm -rf outputs/recon_wavs
    bash encoding_decoding.sh --stage 2 --batch_size 16 --num_workers 4 --gpu_devices "0" \
      --model_dir ${model_dir} --bit_width $bit_width --file_sampling_rate $file_sampling_rate \
      --sample_frequency $sample_frequency \
      --model_name ${model_name} \
      --use_scale $use_scale \
      --wav_scp outputs/codecs/codecs.txt --out_dir outputs/recon_wavs
    
    # move the results to the right place
    python3 move_reconstructed_wavs.py --input_wav_scp $input_wav_scp \
           --org_prefix_dir $ref_audio_dir \
           --cur_prefix_dir $syn_audio_dir \
           --recon_wavs_dir outputs/recon_wavs
      
    rm -rf outputs/codecs outputs/recon_wavs
done