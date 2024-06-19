#cd /raid/slyne/FunCodec/egs/codecSuperb

#conda activate funcodec
#model_name=valid.generator_multi_spectral_recon_loss.best.pth
#model_name=valid.generator_multi_spectral_recon_loss.ave_60best.pth
#model_dir=encodec_16k_n32_600k_step_ds640
#model_name=30epoch.pth
#model_dir=audio_codec-encodec-en-libritts-16k-nq32ds640-pytorch
#model_dir=ngc_best_checkpoint
model_dir=encodec_16k_n32_600k_step_ds640
model_name=valid.generator_multi_spectral_recon_loss.best.pth
bit_width=16000

use_scale=true

sample_rates=(44100 48000 16000)
for file_sampling_rate in ${sample_rates[@]}; do
    # encode wav
    input_wav_scp=/raid/slyne/codec_evaluation/test_wavscp/${file_sampling_rate}_wav.scp
    # decode codec
    rm -rf outputs/codecs
    bash encoding_decoding.sh --stage 1 --batch_size 16 --num_workers 4 --gpu_devices "2,3"   \
        --model_dir exp/${model_dir} --bit_width $bit_width \
        --model_name ${model_name} \
        --wav_scp $input_wav_scp  \
        --out_dir outputs/codecs \
        --file_sampling_rate $file_sampling_rate \
        --use_scale $use_scale
    
    # decode wav
    rm -rf outputs/recon_wavs
    bash encoding_decoding.sh --stage 2 --batch_size 16 --num_workers 4 --gpu_devices "2,3" \
      --model_dir exp/${model_dir} --bit_width $bit_width --file_sampling_rate $file_sampling_rate \
      --model_name ${model_name} \
      --use_scale $use_scale \
      --wav_scp outputs/codecs/codecs.txt --out_dir outputs/recon_wavs
    
    # move the results to the right place
    python3 /raid/slyne/codec_evaluation/move_reconstructed_wavs.py --input_wav_scp $input_wav_scp \
           --org_prefix_dir /raid/slyne/codec_evaluation/Codec-SUPERB/data/ \
           --cur_prefix_dir /raid/slyne/codec_evaluation/Codec-SUPERB/recon_data/ \
           --recon_wavs_dir /raid/slyne/FunCodec/egs/codecSuperb/outputs/recon_wavs
      
    rm -rf outputs/codecs outputs/recon_wavs
done