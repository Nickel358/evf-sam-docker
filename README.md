# evf-sam-docker
Provides a Docker container environment for running the [EVF-SAM](https://github.com/hustvl/EVF-SAM/tree/main) demo.

## Usage
Execute the following on the localhost:
```bash
docker-compose up -d
docker-compose exec app bash
```
Execute the following within the container:
```bash
python app.py ../evf-sam
```
Wait for the app.py to finish loading the model weights.

Then, access http://localhost:10001/ in your local browser.