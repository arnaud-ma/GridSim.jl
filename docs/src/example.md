# Example

```@meta
CurrentModule = GridSim
```

Let's create a game with this 3 informations:

```julia
using GridSim
using Colors: RGB
rule = neigh_disk
seed = 1
first_day = firstday((60, 60), (20, 20), RGB)
game = newgame(first_day, rule, rng=seed)
```

Now the first day looks like this:

![image](assets/first_day_color.svg)

We can now iterate over the game's days using the [`days`](@ref) function. For example, to visualize the first 30 days in live:

```julia
using Plots

for day in days(game, 30, copydays=false)
    sleep(0.1)
    display(plot(day, ticks=false, border=:none))
end
```

Note that we used `copydays=false` to avoid copying the days at each iteration. This can
be done only because we don't need to keep the previous days in memory. If you want to get
avery days, you can just do `collect(days(game, 30))`.

Now we want to save the game in a video file

```julia
using VideoIO
using ProgressMeter

# weird bug with the default format, so we need to specify it
open_video(args...) = open_video_out(args..., target_pix_fmt=VideoIO.AV_PIX_FMT_YUV420P)

all_days = collect(days(game)) # collect all the days (until there is only one color)
first_frame = enlarge(firstday(game), 18)
open_video(name="game.mp4", first_frame, framerate=10) do writer
    @showprogress for frame in framestack
        write_frame(video, enlarge(frame, 18))
    end
end
```

It will take some time to generate the video, but you should have a file named `game.mp4` that looks like this <https://www.youtube.com/watch?v=aSCUlpiplb0>.

Note that we used [`GridSim.enlarge`](@ref) to make the video bigger and have a better resolution.

We can also make a graph of the number of colors over time:

```julia
using StatsBase: countmap
counts = countmap.(all_days)
y = [[get(count_day, i, 0) for count_day in counts] for i in keys(counts[1])]
plot(y, xlabel="Day", ylabel="Number of cells", legend=false)
```

And lots of other things, just use the `days` function to iterate or collect the days and then do whatever you want with them.
