import * as toolLib from 'azure-pipelines-tool-lib/tool';
import tl = require("azure-pipelines-task-lib/task");
import tr = require("azure-pipelines-task-lib/toolrunner");
import * as os from 'os';
import * as path from 'path';
import * as util from 'util';

const osPlat: string = os.platform();
const osArch: string = os.arch();
const cacheKey = 'hugo';

async function run() {
    try {
        tl.setResourcePath(path.join(__dirname, "task.json"));

        // download version
        const hugoVersion: string = tl.getInput("hugoVersion", false);
        const extendedVersion: boolean = tl.getBoolInput('extendedVersion', false);

        await getHugo(hugoVersion, extendedVersion);

        const source: string = tl.getPathInput('source', true, false);
        const destination: string = tl.getPathInput('destination', true, false);
        const baseURL: string = tl.getInput('baseURL', false);
        const buildDrafts: boolean = tl.getBoolInput('buildDrafts', false);
        const buildExpired: boolean = tl.getBoolInput('buildExpired', false);
        const buildFuture: boolean = tl.getBoolInput('buildFuture', false);
        const additionalArgs: string = tl.getInput('additionalArgs', false);

        const hugoPath = tl.which(cacheKey, true);
        const hugo: tr.ToolRunner = tl.tool(hugoPath);

        hugo.argIf(source, ['--source',source]);
        hugo.argIf(destination, ['--destination',destination]);
        hugo.argIf(baseURL, ['--baseURL ',baseURL]);
        hugo.argIf(buildDrafts, '--buildDrafts');
        hugo.argIf(buildExpired, '--buildExpired');
        hugo.argIf(buildFuture, '--buildFuture');

        // implicit flags
        hugo.line(' --i18n-warnings --path-warnings --verbose');
        hugo.line(additionalArgs);

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

    ////toolPath = path.join(toolPath, 'bin');
    //
    // prepend the tools path. instructs the agent to prepend for future tasks
    //
    toolLib.prependPath(toolPath);
}

async function acquireHugo(version: string, extendedVersion: boolean): Promise<string> {
    //
    // Download - a tool installer intimately knows how to get the tool (and construct urls)
    //
    const fileName: string = getFileName(version, extendedVersion);
    const downloadUrl: string = getDownloadUrl(version, fileName);
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
    tl.assertAgent('2.105.7');

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
    /////const toolRoot = path.join(extPath, cacheKey);
    return await toolLib.cacheDir(extPath, cacheKey, version);
}

function getFileName(version: string, extendedVersion: boolean): string {
    // 'aix', 'darwin', 'freebsd', 'linux', 'openbsd', 'sunos', and 'win32'.
    const platform: string = osPlat == "win32" ? "windows" : osPlat;
    // 'arm', 'arm64', 'ia32', 'mips', 'mipsel', 'ppc', 'ppc64', 's390', 's390x', 'x32', and 'x64'.
    const arch: string = osArch == "x64" ? "64bit" : "33bit";
    const ext: string = osPlat == "win32" ? "zip" : "tar.gz";
    const filename: string = extendedVersion
        ? util.format("hugo_extended_%s_%s-%s.%s", version, platform, arch, ext)
        : util.format("hugo_%s_%s-%s.%s", version, platform, arch, ext);
    return filename;
}

function getDownloadUrl(version: string, filename: string): string {
    return util.format("https://github.com/gohugoio/hugo/releases/download/v%s/%s", version, filename);
}


run();