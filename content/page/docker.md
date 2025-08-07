---
title: Docker
type: Page
---

### Docker Compose

To run Docker Compose do this:

```bash
docker-compose up --build
```

The parameter `--build` is optional. It will build the images if they don't
exist. If you don't use it, it will use the images that are already built.
Normally you will need to include it as you want everything rebuilt.

Add the parameter `--progress=plain` to see the progress of the build without it
being hidden by the Docker Compose output.

Add the paramater `--detach` (or `-d`) to run the containers in the background.

### Rebuild One of the Images in Docker Compose

To rebuild one of the images in Docker Compose do this:

```bash
docker-compose up -d --no-deps --build <service-name>
```

