import * as toolLib from 'azure-pipelines-tool-lib/tool';
import tl = require("azure-pipelines-task-lib/task");
import tr = require("azure-pipelines-task-lib/toolrunner");
import * as os from 'os';
import * as path from 'path';
import * as util from 'util';

let osPlat: string = os.platform();
let osArch: string = os.arch();
const cacheKey = 'hugo';

async function run(): Promise<void> {
    try {
        tl.setResourcePath(path.join(__dirname, "task.json"));

        // download version
        let hugoVersion: string = tl.getInput("hugoVersion", false);
        let extendedVersion: boolean = tl.getBoolInput('extendedVersion', false);

        await getHugo(hugoVersion, extendedVersion);

        let source: string = tl.getPathInput('source', true, false);
        let destination: string = tl.getPathInput('destination', true, false);
        let baseURL: string = tl.getInput('baseURL', false);
        let buildDrafts: boolean = tl.getBoolInput('buildDrafts', false);
        let buildExpired: boolean = tl.getBoolInput('buildExpired', false);
        let buildFuture: boolean = tl.getBoolInput('buildFuture', false);
        let uglyURLs: boolean = tl.getBoolInput('uglyURLs', false);;

        let hugoPath = tl.which(cacheKey, true);
        let hugo: tr.ToolRunner = tl.tool(hugoPath);

        hugo.argIf(source, '--source ' + source);
        hugo.argIf(destination, '--destination ' + destination);
        hugo.argIf(baseURL, '--baseURL ' + baseURL);
        hugo.argIf(buildDrafts, '--buildDrafts');
        hugo.argIf(buildExpired, '--buildExpired');
        hugo.argIf(buildFuture, '--buildFuture');
        hugo.argIf(uglyURLs, '--uglyURLs');

        // implicit flags
        hugo.line(' --enableGitInfo --i18n-warnings --verbose');

        await hugo.exec();

    } catch (error) {
        tl.setResult(tl.TaskResult.Failed, error);
    }
}

async function getHugo(version: string, extendedVersion: boolean): Promise<void> {
    // check cache
    let toolPath: string;
    toolPath = toolLib.findLocalTool(cacheKey, version);

    if (!toolPath) {
        // download, extract, cache
        toolPath = await acquireHugo(version, extendedVersion);
        tl.debug("Hugo tool is cached under " + toolPath);
    }

    toolPath = path.join(toolPath, 'bin');
    //
    // prepend the tools path. instructs the agent to prepend for future tasks
    //
    toolLib.prependPath(toolPath);
}

async function acquireHugo(version: string, extendedVersion: boolean): Promise<string> {
    //
    // Download - a tool installer intimately knows how to get the tool (and construct urls)
    //
    let fileName: string = getFileName(version, extendedVersion);
    let downloadUrl: string = getDownloadUrl(version, fileName);
    let downloadPath: string = null;
    try {
        downloadPath = await toolLib.downloadTool(downloadUrl);
    } catch (error) {
        tl.debug(error);

        // cannot localized the string here because to localize we need to set the resource file.
        // which can be set only once. azure-pipelines-tool-lib/tool, is already setting it to different file.
        // So left with no option but to hardcode the string. Other tasks are doing the same.
        throw (util.format("Failed to download version %s. Please verify that the version is valid and resolve any other issues. %s", version, error));
    }

    //make sure agent version is latest then 2.115.0
    tl.assertAgent('2.115.0');

    //
    // Extract
    //
    let extPath: string;
    extPath = tl.getVariable('Agent.TempDirectory');
    if (!extPath) {
        throw new Error("Expected Agent.TempDirectory to be set");
    }

    if (osPlat == 'win32') {
        extPath = await toolLib.extractZip(downloadPath);
    }
    else {
        extPath = await toolLib.extractTar(downloadPath);
    }

    //
    // Install into the local tool cache - node extracts with a root folder that matches the fileName downloaded
    //
    let toolRoot = path.join(extPath, cacheKey);
    return await toolLib.cacheDir(toolRoot, cacheKey, version);
}

function getFileName(version: string, extendedVersion: boolean): string {
    // 'aix', 'darwin', 'freebsd', 'linux', 'openbsd', 'sunos', and 'win32'.
    let platform: string = osPlat == "win32" ? "windows" : osPlat;
    // 'arm', 'arm64', 'ia32', 'mips', 'mipsel', 'ppc', 'ppc64', 's390', 's390x', 'x32', and 'x64'.
    let arch: string = osArch == "x64" ? "amd64" : "386";
    let ext: string = osPlat == "win32" ? "zip" : "tar.gz";
    let filename: string = extendedVersion
        ? util.format("hugo_extended_%s_%s-%s.%s", version, platform, arch, ext)
        : util.format("hugo_%s_%s-%s.%s", version, platform, arch, ext);
    return filename;
}

function getDownloadUrl(version: string, filename: string): string {
    return util.format("https://github.com/gohugoio/hugo/releases/download/v%s/%s", version, filename);
}


run();