function exportExampleMedia(raptorRoot, examples)
% exportExampleMedia Export the example figures and videos of the docs.
%
%   exportExampleMedia(raptorRoot) runs the RAPTOR examples found in the
%   raptorRoot folder, and exports the selected figure of each example as
%   a png image, together with the dashboard videos shown on the home page.
%   The files are written to docs/assets/examples, next to this script.
%
%   exportExampleMedia(raptorRoot, examples) only exports the media of the
%   listed examples.
%
%   Inputs:
%       raptorRoot - string, root folder of the raptor-matlab repository
%       examples   - string array, example folders to export (default: all)
%
%   Example:
%       exportExampleMedia("C:/Repositories/raptor-matlab")
%       exportExampleMedia("C:/Repositories/raptor-matlab", ["13-hypersonicEntry" "14-rocketAscent"])

arguments
    raptorRoot (1, 1) string
    examples (1, :) string = "all"
end

% figure exported for each example: "states" is the automatic states
% figure, "auxiliary k" the k-th figure created by the auxiliary plotting
% function, and "dashboard" the last frame of the animated dashboard
media = [ ...
    "00-doubleIntegrator"           "states"
    "01-landing1D"                  "auxiliary 1"
    "02-breakwell"                  "auxiliary 2"
    "03-brachistochrone"            "auxiliary 1"
    "04-zermelo"                    "auxiliary 1"
    "05-gong"                       "states"
    "06-goddardRocket"              "states"
    "07-orbitRaising"               "auxiliary 1"
    "08-rlvReturn"                  "auxiliary 1"
    "09-marsLanding3DoF"            "auxiliary 2"
    "10-windyLanding3DoF"           "auxiliary 1"
    "11-shuttleReentry"             "auxiliary 2"
    "12-shuttleReentryMinHeating"   "auxiliary 2"
    "13-hypersonicEntry"            "dashboard"
    "14-rocketAscent"               "dashboard"
    "15-marsLanding6DoF"            "auxiliary 1"];

% dashboard videos, recorded through the visualization function of the
% example (called with the solution and the video file)
videos = [ ...
    "13-hypersonicEntry"            "visualizeEntry"
    "14-rocketAscent"               "visualizeAscent"];

% keep only the requested examples
if ~isequal(examples, "all")
    media = media(ismember(media(:, 1), examples), :);
end

% output folder and figure size of the exported images
outputFolder = fullfile(fileparts(mfilename("fullpath")), "..", "docs", "assets", "examples");
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
figureSize = [900 560];

% add RAPTOR to the path (quietly)
originalFolder = pwd;
cleanup = onCleanup(@() cd(originalFolder));
cd(raptorRoot);
RAPTOR_init(0);
basePath = path;

% loop over all examples
for ee = 1 : size(media, 1)
    example = media(ee, 1);
    fprintf("Exporting %s ... ", example);
    cd(fullfile(raptorRoot, "examples", example));
    close all
    try
        % solve with all the plots enabled
        sol = runExample();

        % export the selected figure
        fig = selectFigure(media(ee, 2));
        if media(ee, 2) ~= "dashboard"
            set(fig, "WindowStyle", "normal", "Position", [100 100 figureSize]);
        end
        exportgraphics(fig, fullfile(outputFolder, example + ".png"), "Resolution", 120);

        % record the dashboard video, if any
        videoFunction = videos(videos(:, 1) == example, 2);
        if ~isempty(videoFunction)
            close all
            feval(videoFunction, sol, fullfile(outputFolder, example + ".mp4"));
        end
        fprintf("done\n");
    catch ME
        fprintf("FAILED (%s)\n", ME.message);
    end

    % restore the path, as examples may add folders with clashing names
    close all
    path(basePath);
end
end

function sol = runExample()
% function that runs the main script of the current example with all the
% plots enabled, and returns its solution
showPlots = true; %#ok<NASGU>
evalc("main");
end

function fig = selectFigure(selection)
% function that returns the figure matching the selection string

% sort the figures by creation order
figures = findall(groot, "Type", "figure");
[~, order] = sort([figures.Number]);
figures = figures(order);
names = string({figures.Name});

% automatic figures are named <problem>:<phase>:<family>:<figure>
isAutomatic = contains(names, [":primal:" ":dual:" ":validation:"]);
isDashboard = contains(names, ":dashboard");
if selection == "states"
    fig = figures(endsWith(names, ":primal:states"));
elseif selection == "dashboard"
    fig = figures(isDashboard);
else
    auxiliary = figures(~isAutomatic & ~isDashboard);
    fig = auxiliary(sscanf(selection, "auxiliary %d"));
end
fig = fig(1);
end
