path = require 'path'
treeViewPackage = atom.packages.loadPackage 'tree-view'
libpath = treeViewPackage.path + path.sep + 'lib' + path.sep
TreeView = require libpath + 'tree-view'
Directory = require libpath + 'directory'
DirectoryView = require libpath + 'directory-view'

module.exports =
  config: {}

atom.contextMenu.add
  '.tree-view .header':
    [
      label: 'Temporary Root'
      submenu:
        [
          { label: 'Enter', command: 'temporary-root:enter-root-mode' }
          { label: 'Exit', command: 'temporary-root:exit-root-mode' }
        ]
    ]

atom.commands.add '.tree-view .header', 'temporary-root:exit-root-mode', () ->
  @treeView ?= treeViewPackage.requireMainModule().treeView
  trm = @treeView.temporaryRootModule
  if trm.originalRoots.length
    trm.selectedRoots = trm.originalRoots.pop()
    @treeView.updateRoots()

atom.commands.add '.tree-view .header', 'temporary-root:enter-root-mode', () ->
  @treeView ?= treeViewPackage.requireMainModule().treeView
  trm = @treeView.temporaryRootModule
  unless trm?
    trm = @treeView.temporaryRootModule =
      originalRoots: [@treeView.roots]
  else
    trm.originalRoots.push @treeView.roots

  trm.selectedRoots = [@treeView.selectedPath]

  @treeView.updateRoots = () ->
    for root in @roots
      try
        @list[0].removeChild root
    @roots = []

    @loadIgnoredPatterns()

    for root in @temporaryRootModule.selectedRoots
      if root.directory?
        root = root.directory.path
      directory = new Directory
        name: path.basename root
        fullPath: root
        symlink: no
        isRoot: yes
        ignoredPatterns: @ignoredPatterns
        expansionState:
          isExpanded: yes

      rootView = new DirectoryView()
      rootView.initialize directory
      @list[0].appendChild rootView
      @roots.push rootView

  @treeView.updateRoots()
