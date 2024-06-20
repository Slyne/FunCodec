# Setup Environment

```
git clone https://github.com/Slyne/FunCodec
cd FunCodec && git checkout slyne_fix && cd ..
```

The tested environment for the below part is based on docker `nvcr.io/nvidia/pytorch:24.04-py3` OR a conda environment should be good as well.

```
# mount the current directory to /ws; You can put your data in your current
# directory as well.
docker run --gpus all -it -v $PWD:/ws  nvcr.io/nvidia/pytorch:24.04-py3

Or

conda create -n funcodec python=3.10
```
### Install packages
```
cd /ws/FunCodec;
pip install --editable ./ ; pip install torchaudio; 
```

### Prepare dataset
Please prepare your dataset similar to `${sampling_rate}_wav.scp` and put them in `/ws/test_wavscp/`
```
44100_wav.scp
48000_wav.scp
16000_wav.scp
```

Each `wav.scp` file looks like below:
```
<wavid> <absolute_path>
WAbHmvQ9zME_00002 /raid/slyne/codec_evaluation/Codec-SUPERB/data/vox1_test_wav/wav/id10302/WAbHmvQ9zME/00002.wav
```

**Example**
Please follow [here](https://github.com/voidful/Codec-SUPERB/tree/SLT_Challenge?tab=readme-ov-file#2-data-download) to download `Codec-SUPERB` test datasets.

```
# suppose the unzip data dir is /ws/data
python3 generate_wavscp.py --input_dir=/ws/data
```

### Download models

Download models from [here](https://huggingface.co/Slyne/funcodec_codecSuperb). And put them under `FunCodec/egs/codecSuperb/models`


### Do inference
Please refer to `FunCodec/egs/codecSuperb/do_codecSuperb_infer.sh` to do inference.


```
# set model to the default model trained with 16khz data
model_dir=models/16k/
model_name=8epoch.pth
sample_rates=(16000 44100 48000)  # the input wavscp sample rate ca be 16khz, 44.1khz or 48khz

```

Run:
```
cd FunCodec/egs/codecSuperb/
# modify the ref_audio_dir and syn_audio_dir
bash do_codecSuperb_infer.sh
```

