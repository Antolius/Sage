project('hr.from.josipantolis.sage', 'vala', 'c')

i18n = import('i18n')
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

gnome = import('gnome')
gresource = gnome.compile_resources(
    'gresource',
    'data' / 'gresource.xml',
    source_dir: 'data'
)

executable(
    meson.project_name(),
    gresource,
    'src' / 'Application.vala',
    'src' / 'Game.vala',
    'src' / 'Hint.vala',
    'src' / 'MainWindow.vala',
    'src' / 'Widgets' / 'BoardGrid.vala',
    'src' / 'Widgets' / 'ColorPickerButton.vala',
    'src' / 'Widgets' / 'Colors.vala',
    'src' / 'Widgets' / 'EndGameDialog.vala',
    'src' / 'Widgets' / 'GuessRow.vala',
    'src' / 'Widgets' / 'GuessToggle.vala',
    'src' / 'Widgets' / 'HeaderBar.vala',
    'src' / 'Widgets' / 'HelpPopover.vala',
    'src' / 'Widgets' / 'HintsGrid.vala',
    'src' / 'Widgets' / 'ValidateRowButton.vala',
    dependencies: [
        dependency('gee-0.8'),
        dependency('gtk+-3.0'),
        dependency('granite'),
        dependency('libhandy-1'),
    ],
    install: true
)

icon_sizes = ['16', '32', '64', '128']

foreach i : icon_sizes
    install_data(
        'data' / 'icons' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: meson.project_name() + '.svg'
    )
    install_data(
        'data' / 'icons' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: meson.project_name() + '.svg'
    )
endforeach

i18n.merge_file(
    input: 'data' / 'sage.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'data' / 'sage.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: meson.source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

subdir('po')

meson.add_install_script('meson/post_install.py')

subdir('data')

