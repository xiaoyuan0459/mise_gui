import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mise_gui/services/mise_process_service.dart';
import 'package:mise_gui/services/mise_query_service.dart';

void main() {
  test('diagnoses missing make for source builds', () {
    final diagnosis = diagnoseMiseCommandFailure(
      command: 'mise install redis@8.6.2',
      stderr:
          'mise [redis] Compiling Redis from source...\n'
          'sh: make: command not found\n'
          'Failed to compile Redis. Make sure you have a C compiler (gcc/clang) and make installed.',
    );

    expect(diagnosis, isNotNull);
    expect(diagnosis!.summary, contains('缺少 make'));
    expect(diagnosis.detail, contains('xcode-select --install'));
  });

  test('diagnoses missing compiler toolchain', () {
    final diagnosis = diagnoseMiseCommandFailure(
      command: 'mise install erlang@27',
      stderr: 'configure: error: no acceptable C compiler found in \$PATH',
    );

    expect(diagnosis, isNotNull);
    expect(diagnosis!.summary, contains('C 编译工具链'));
    expect(diagnosis.detail, contains('clang --version'));
  });

  test('parses shell environment output with startup banner noise', () {
    final environment = parseShellEnvironmentOutput(
      'Welcome back to zsh!\n'
      '__MISE_GUI_SHELL_ENVIRONMENT_START__\u0000'
      'PATH=/usr/local/bin:/usr/bin\u0000'
      'HOME=/Users/demo\u0000'
      '__MISE_GUI_SHELL_ENVIRONMENT_END__\u0000',
    );

    expect(environment['PATH'], '/usr/local/bin:/usr/bin');
    expect(environment['HOME'], '/Users/demo');
    expect(environment.length, 2);
  });

  test('parses proxy environment from mise config env section', () {
    final environment = parseMiseProxyEnvironmentFromConfig(
      '[tools]\n'
      'node = "20"\n'
      '\n'
      '[env]\n'
      'https_proxy = "http://127.0.0.1:7890"\n'
      'no_proxy = "localhost,127.0.0.1"\n',
    );

    expect(environment['https_proxy'], 'http://127.0.0.1:7890');
    expect(environment['HTTPS_PROXY'], 'http://127.0.0.1:7890');
    expect(environment['no_proxy'], 'localhost,127.0.0.1');
    expect(environment['NO_PROXY'], 'localhost,127.0.0.1');
  });

  test('resolves HttpClient proxy configuration from proxy environment', () {
    final proxy = resolveHttpClientProxyConfiguration(
      Uri.parse('https://api.github.com/repos/jdx/mise'),
      const {'https_proxy': 'http://127.0.0.1:7890'},
    );
    final direct = resolveHttpClientProxyConfiguration(
      Uri.parse('https://localhost/status'),
      const {
        'https_proxy': 'http://127.0.0.1:7890',
        'no_proxy': 'localhost,127.0.0.1',
      },
    );

    expect(proxy, 'PROXY 127.0.0.1:7890; DIRECT');
    expect(direct, 'DIRECT');
  });

  test('extracts resolved executable path from noisy shell output', () {
    const resolved = MiseResolvedExecutableRef(
      subject: 'node',
      command: 'command -v node',
      exitCode: 0,
      stdout:
          'Last login: Thu May  7 09:00:00 on ttys000\n'
          '/Users/demo/.local/share/mise/shims/node\n',
      stderr: '',
    );

    expect(resolved.resolvedPath, '/Users/demo/.local/share/mise/shims/node');
  });

  test('prefers utf8 for Windows command output', () {
    const output = '找不到与输入条件匹配的已安装程序包。';

    expect(
      decodeMiseProcessOutput(utf8.encode(output), preferUtf8: true),
      output,
    );
  });

  test(
    'collectWindowsMiseShimCandidates puts MISE_DATA_DIR shims first',
    () {
      final candidates = collectWindowsMiseShimCandidates(
        environment: const {
          'MISE_DATA_DIR': r'D:\data\mise\mise-data',
          'LOCALAPPDATA': r'C:\Users\demo\AppData\Local',
          'USERPROFILE': r'C:\Users\demo',
        },
      );

      expect(candidates.first, r'D:\data\mise\mise-data\shims');
      expect(candidates, contains(r'C:\Users\demo\AppData\Local\mise\shims'));
      expect(
        candidates,
        contains(r'C:\Users\demo\.local\share\mise\shims'),
      );
    },
  );

  test('looksLikeMiseShimsEntry recognizes custom MISE_DATA_DIR layout', () {
    expect(looksLikeMiseShimsEntry(r'd:\data\mise\mise-data\shims'), isTrue);
    expect(looksLikeMiseShimsEntry(r'c:\users\demo\appdata\local\mise\shims'), isTrue);
    expect(looksLikeMiseShimsEntry(r'c:\some\other\bin'), isFalse);
    expect(looksLikeMiseShimsEntry(r'd:\tools\scoop\shims'), isFalse);
  });

  test('explicitMiseGlobalConfigPath prefers MISE_GLOBAL_CONFIG_FILE', () {
    expect(
      explicitMiseGlobalConfigPath(environment: const {
        'MISE_GLOBAL_CONFIG_FILE': r'C:\conf\my-config.toml',
        'MISE_CONFIG_DIR': r'C:\conf\mise',
      }),
      r'C:\conf\my-config.toml',
    );
    expect(
      explicitMiseGlobalConfigPath(environment: const {
        'MISE_CONFIG_DIR': r'/opt/mise-conf',
      }),
      '/opt/mise-conf/config.toml',
    );
    expect(
      explicitMiseGlobalConfigPath(environment: const {'HOME': '/home/demo'}),
      isNull,
    );
  });

  test('resolveGlobalMiseConfigPath falls back to HOME when unset', () {
    expect(
      resolveGlobalMiseConfigPath(environment: const {'HOME': '/home/demo'}),
      '/home/demo/.config/mise/config.toml',
    );
    expect(
      resolveGlobalMiseConfigPath(environment: const {
        'MISE_CONFIG_DIR': '/custom/mise',
      }),
      '/custom/mise/config.toml',
    );
  });

  test('isGlobalMiseConfigPath detects resolved and .config/mise layouts', () {
    expect(
      isGlobalMiseConfigPath(
        r'C:\home\demo\.config\mise\config.toml',
        environment: const {'HOME': r'C:\home\demo'},
      ),
      isTrue,
    );
    expect(
      isGlobalMiseConfigPath('/custom/mise/config.toml', environment: const {
        'MISE_CONFIG_DIR': '/custom/mise',
      }),
      isTrue,
    );
    expect(
      isGlobalMiseConfigPath('/repo/mise.toml', environment: const {
        'HOME': '/home/demo',
      }),
      isFalse,
    );
  });

  test('isMiseCommandUnavailable ignores generic not found in stderr', () {
    // 工具自身安装/检查输出里的 "not found" 不应被误判成 mise 缺失。
    final error = MiseProcessException(
      message: 'mise command failed with exit code 1',
      result: const MiseCommandResult(
        request: MiseCommandRequest(arguments: <String>['install', 'x']),
        stdout: '',
        stderr: 'mise x 1.0.0 failed: binary not found in archive\n',
        exitCode: 1,
        duration: Duration.zero,
      ),
    );

    expect(isMiseCommandUnavailable(error), isFalse);
  });

  test('isMiseCommandUnavailable detects launch-level failure', () {
    final error = MiseProcessException(
      message: 'Unable to launch mise CLI from the desktop app',
      result: const MiseCommandResult(
        request: MiseCommandRequest(arguments: <String>['--version']),
        stdout: '',
        stderr: 'foo: command not found\n',
        exitCode: 127,
        duration: Duration.zero,
      ),
    );

    expect(isMiseCommandUnavailable(error), isTrue);
  });
}
