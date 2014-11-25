# Video Transcoding Scripts

Utilities to transcode, inspect and convert videos.

## About

Hi, I'm [Martin Storbeck] (http://storbeck.me), I have forked theses video transcoding scripts by [Don Melton](http://donmelton.com/). He originally wrote these scripts to transcode his collection of Blu-ray Discs and DVDs into a smaller, more portable format while remaining high enough quality to be mistaken for the originals.

For me the scripts came in handy, but needed some modification from my point of view. I forked them to enhance the batch conversion functionality and integrate a CPU limiter for handbrake.


All of these scripts are written in [Bash](http://www.gnu.org/software/bash/) and leverage excellent Open Source and cross-platform software like [HandBrake](https://handbrake.fr/), [MKVToolNix](https://www.bunkus.org/videotools/mkvtoolnix/), [MPlayer](http://mplayerhq.hu/), [FFmpeg](http://ffmpeg.org/), and [MP4v2](https://code.google.com/p/mp4v2/). These scripts are essentially intelligent wrappers around these other tools, designed to be executed from the command line shell.

Even if you don't use any of these scripts, you may find their source code or this "README" document helpful.

### Transcoding presets in `transcode-video.sh`

The primary script is `transcode-video.sh` and was written because the preset system built into HandBrake wasn't quite powerful enough to automatically change bitrate and other encoding options based on different inputs. Plus, HandBrake's default presets themselves didn't produce a predictable output size with sufficient quality.

HandBrake's "AppleTV 3" preset is closest to the desired output, but results in a huge video bitrate of 19.9 Mbps, very close the original of 22.9 Mbps. And sometimes transcoding with much smaller output size lacks detail compared to the original.

Videos from the [iTunes Store](https://en.wikipedia.org/wiki/ITunes_Store) were the template for a smaller and more portable transcoding format. Their files are very good quality, only about 20% the size of the same video on a Blu-ray Disc, and play on a wide variety of devices.

To follow that template, the `transcode-video.sh` script configures the [x264 video encoder](http://www.videolan.org/developers/x264.html) within HandBrake to use a [constrained variable bitrate (CVBR)](https://en.wikipedia.org/wiki/Variable_bitrate) mode, and to automatically target bitrates appropriate for different input resolutions.

## Requirements

All of these scripts work on OS X because that's the platform where they are developed, tested and used. But none of them actually require OS X so, technically, they should also work on Windows and Linux. Your mileage may vary.

Since these scripts are essentially intelligent wrappers around other software, they do require certain command line tools to function. Most of these dependencies are available via [Homebrew](http://brew.sh/), a package manager for OS X. However, HandBrake is available via [Homebrew Cask](http://caskroom.io/), an extension to Homebrew.

HandBrake can also be downloaded and installed manually.

Tool | Transcoding | Crop detection | Conversion | Package | Cask
--- | --- | --- | --- | --- | ---
`HandBrakeCLI` | required | required | | | `handbrakecli`
`mkvpropedit` | required | | | `mkvtoolnix` | &nbsp;
`mplayer` | | required | | `mplayer` | &nbsp;
`mkvmerge` | | | required | `mkvtoolnix` | &nbsp;
`ffmpeg` | | | required | `ffmpeg` | &nbsp;
`mp4track` | | | required | `mp4v2` | &nbsp;
`cpulimit` | limit CPU usage | | | `cpulimit` | &nbsp;

Installing a package with Homebrew is as simple as:

    brew install mkvtoolnix

To install both Homebrew Cask and `HandBrakeCLI`, the command line version of HandBrake:

    brew install caskroom/cask/brew-cask
    brew cask install handbrakecli

But that version of HandBrake may contain out-of-date libraries since the development team only does an official release about once a year. Nightly builds of HandBrake are much more up to date and usually very stable.

To install both Homebrew Cask and a nightly build of `HandBrakeCLI`:

    brew install caskroom/cask/brew-cask
    brew cask install caskroom/versions/handbrakecli-nightly

## Installation

As of now, the scripts must be installed manually.

You can retrieve them via the command line by cloning the entire repository like this:

    cd "/folder/where/you/want/to/install/the/scripts/"
    git clone https://github.com/hdready/video-transcoding-scripts.git

In some cases you might need to set permissions to execute the scripts like this:

    chmod +x transcode-video.sh

## Batch control for `transcode-video.sh`

Although `transcode-video.sh` doesn't handle multiple inputs, the included `crop-transcode-batch.sh` script adds an always on functionality. The original batch-control for `transcode-video.sh` was written by Don, I enhanced it for the always on approach. 

Move the video files you want to transcode or have ripped with MakeMKV to the `transcode/` folder. All files in this folder will be transcoded and end up in the `done/` folder. Files that are added to the `transcode/` folder after you started `crop-transcode-batch.sh` will be transcoded when all previously existing files are finished.

You can also specify a folder to move the files to after transcoding (e.g. the folder you keep your movies in). The batch-script will transcode your videos in the `done/` folder and move them to your specified output folder when the enconding is finished. After starting `crop-transcode-batch.sh` you will be asked if you want to move the files or not. press `y` to specify the folder all files will be moved to when they are finished transcoding. The .log-file will remain in the `done/` folder

As the name indicates, `crop-transcode-batch.sh` will check for crop values first using `detect-crop.sh` and transcode later with `transcode-video.sh`. 

In its current configuration, the batch-script will use the following options:

`--mkv` (output in mkv container)
`--big` (larger bitrates for better quality)
`--slow` (use more CPU time to have better quality results)
`--add-audio 2, 3 & 4` (by default add the first four audio tracks of the source file)
`--add-suffix enc` (output the file as `original-name.enc.mkv` to indicate that this is a file you encoded yourself)

You may change these to your preference (check `transcode-video.sh --help` to view other options). Therefore you need to edit `crop-transcode-batch.sh`. 

`transcode-video.sh` was modified so ac3- & aac-audio tracks from the source file are copied without conversion, multi-channel-input is encoded in ac3-640 and other audio is encoded in aac. Up to 9 subtitles are added to the file automatically.

When `transcode-video.sh` finishes, the crop-file of that movie is also removed from the `crops/` folder. 

When all files are transcoded, `crop-transcode-batch.sh` will wait for 10 minutes and then check if new files have been moved to the `transcode/` folder. In case there are no new files, it will wait again for 10 minutes and re-check. This will go on until you manually end the process.

## Autorun `crop-transcode-batch.sh`

To autorun `crop-transcode-batch.sh` on startup, create a file named `crop-transcode-autorun.command` and put in the following content:

    cd "/path/to/folder/done/"
    crop-transcode-batch.sh

On your mac, go into `System Settings`, select `Users & Groups`, select your user account, then `login objects` and press `+`. Choose the `crop-transcode-autorun.command` you just created and you're done. 

## Feedback

The best way to send feedback is mentioning me, [@hdready](http://twittter.com/hdready) or the original creator of the scripts, [@donmelton](https://twitter.com/donmelton), on Twitter. 

## License

Video Transcoding Scripts is copyright [Don Melton](http://donmelton.com/) and available under a [MIT license](https://github.com/donmelton/video-transcoding-scripts/blob/master/LICENSE).
