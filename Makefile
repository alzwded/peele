DISTNAME = peele-0.9
DEPS = ./UI/DBPicker.pm \
./UI/PeeleApplication.pm \
./UI/PluginSettings.pm \
./UI/ResultsDisplay.pm \
./UI/HelpAbout.pm \
./UI/ChainEditor.pm \
./UI/Components/ListEditor.pm \
./UI/Components/FieldEditor.pm \
./UI/Components/PluginConfig.pm \
./UI/Components/ProgressMonitor.pm \
./LICENSE \
./help.html \
./peele.pl \
./Core/ExpressionEngine.pm \
./Core/Document.pm \
./Core/DBEngine.pm \
./Core/PluginManager.pm \
./Plugins/SQLiteDB.pm \
./README.md \
./sql/schema.sql \

$(DISTNAME).txz: $(DEPS)
	mkdir -p dist
	tar cv $(DEPS) | tar xv -C dist/
	mv dist $(DISTNAME)
	tar cJvf $(DISTNAME).txz $(DEPS)
	mv $(DISTNAME) dist

clean:
	rm -rf dist $(DISTNAME).txz
