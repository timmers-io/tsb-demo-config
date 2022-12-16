# eShop demo application

This is a demo application based on the obs-tester that can be used to play
with tenancy in TSB as well as the telemetry parts of the product.

It consists of two applications:

* `eshop`: Contains the `eshop` and `checkout` namespaces.
* `payments`: Contains the `payments` namespaces.

The `payments` service is configured to introduce a 200ms latency, and the `checkout`
service is configured to fail 20% of the requests.

By default, it uses the testing LDAP as the Identity provider, and the following users
are configured. However, custom users can be designated as owners of the different applications
by configuring the environment variables as explained in the table at the end.

* `nacx/nacx-pass`: Is a Creator on the eshop tenant.
* `zack/zack-pass`: Is the owner of the eshop workspace.
* `wusheng/wusheng-pass`: Is the owner of the payments workspace.

## Deploy the application

This assumes access to a TSB installation. The installation script will deploy all
the obs-tester instances, configure TSB, the ingress gateways, and install a
traffic generator.

You can deploy it with:

```bash
./deploy.sh
```

You can configure the following environment variables as well to customize the installation:

| Variable | Default value | Description                                                    |
|---|---|---|
| HUB | gcr.io/tetrate-internal-containers | Where the obs-tester image will be pulled from                 |
| OBSTESTER_TAG | 1.0 | The obs-tester image tag                                       |
| ESHOP_HOST | eshop.tetrate.io | Hostname to expose the main eshop app in an ingress gateway    |
| PAYMENTS_HOST | payments.tetrate.io | Hostname to expose the main payments app in an ingress gateway |
| TENANT_OWNER | nacx | Username of the owner of the eShop tenant                      |
| ESHOP_OWNER | zack | Username of the owner of the eShop workspace                   |
| PAYMENTS_OWNER | wusheng | Username of the owner of the payments workspace                |
