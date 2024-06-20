import soundfile
import os
import argparse

def generate_wavscp(input_dir, output_wavscp_dir, add_dirname=True):
    sr_filelist = {}
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file.endswith('.wav'):
                file_path = os.path.join(root, file)
                # use absolute path to avoid errors
                file_path = os.path.abspath(file_path)
                data, sr = soundfile.read(file_path)
                sr_filelist[sr] = sr_filelist.get(sr, [])
                sr_filelist[sr].append(file_path)
            elif file.endswith('.flac'):
                file_path = os.path.join(root, file)
                # use absolute path to avoid errors
                file_path = os.path.abspath(file_path)
                data, sr = soundfile.read(file_path)
                # convert it to .wav
                file_path = file_path.replace('.flac', '.wav')
                soundfile.write(file_path, data, sr)
                sr_filelist[sr] = sr_filelist.get(sr, [])
                sr_filelist[sr].append(file_path)
                
    os.makedirs(output_wavscp_dir, exist_ok=True)
    for sr, filelist in sr_filelist.items():
        with open(os.path.join(output_wavscp_dir, f'{sr}_wav.scp'), 'w') as f:
            for file in filelist:
                filename = os.path.splitext(os.path.basename(file))[0]
                if add_dirname:
                    directory = os.path.dirname(file).split("/")[-1]
                    filename = directory + "_" + filename
                    f.write(f'{filename} {file}\n')
                else:     
                    f.write(f'{filename} {file}\n')
                    
    print('Done!')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate wav.scp files for different sampling rates')
    parser.add_argument('--input_dir', type=str, help='input directory')
    parser.add_argument('--output_wavscp_dir', default='test_wavscp/', type=str, help='output directory for wav.scp files')
    args = parser.parse_args()
    generate_wavscp(args.input_dir, args.output_wavscp_dir)
    