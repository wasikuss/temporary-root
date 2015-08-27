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
	if @treeView.temporaryRootModule?.enabled is yes
		@treeView.temporaryRootModule.enabled = no

		@treeView.updateRoots = @treeView.constructor.prototype.updateRoots
		@treeView.updateRoots()

atom.commands.add '.tree-view .header', 'temporary-root:enter-root-mode', () ->
	@treeView ?= treeViewPackage.requireMainModule().treeView
	unless @treeView.temporaryRootModule?
		@treeView.temporaryRootModule =
			enabled: no
			originalRoots: @treeView.roots

	if @treeView.temporaryRootModule.enabled is no
		@treeView.temporaryRootModule.selectedRoot = @treeView.selectedPath

		@treeView.updateRoots = () ->
			for root in @roots
 				@list[0].removeChild root
			@roots = []

			@loadIgnoredPatterns()

			directory = new Directory
				name: path.basename @temporaryRootModule.selectedRoot
				fullPath: @temporaryRootModule.selectedRoot
				symlink: no
				isRoot: yes
				ignoredPatterns: @ignoredPatterns
				expansionState:
					isExpanded: yes

			root = new DirectoryView()
			root.initialize directory
			@list[0].appendChild root
			@roots.push root

			return

	@treeView.temporaryRootModule.enabled = yes
	@treeView.updateRoots()
