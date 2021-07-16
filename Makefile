docker: minimap2
	docker build -t minimap2-scatter .

minimap2:
	make -C minimap2 -j 4

.PHONY: minimap2 docker