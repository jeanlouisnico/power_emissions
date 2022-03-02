import requests
import json 


headers = {'content-type': 'application/json'}
query = """
    {
        electricityprodex5minrealtime(order_by: {Minutes5UTC: desc} limit: 100 offset: 0) {
            Minutes5UTC
            Minutes5DK
            PriceArea
            ProductionLt100MW
            ProductionGe100MW
            OffshoreWindPower
            OnshoreWindPower
            SolarPower
            ExchangeGreatBelt
            ExchangeGermany
            ExchangeNetherlands
            ExchangeNorway
            ExchangeSweden
            BornholmSE4
        }
    }
    """

request = requests.post('https://data-api.energidataservice.dk/v1/graphql', json={'query': query}, headers=headers)
data = request.json()
with open('data.json', 'w') as f:
    json.dump(data, f)