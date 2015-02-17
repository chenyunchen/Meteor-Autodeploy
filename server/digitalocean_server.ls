@Digitalocean = {}


OAuth.registerService('digitalocean', 2, null, (query)->
  result = getAccessToken(query)
  accessToken = result.access_token
  identity = result.info
  return {
    serviceData:
      id: result.uid
      accessToken: OAuth.sealSecret(accessToken)
      email:identity.email
      username: identity.name
    options:
      profile:
        name: identity.name
  }
)

userAgent = 'Meteor'
if Meteor.release
  userAgent += '/' + Meteor.release

getAccessToken = (query)->
  config = ServiceConfiguration.configurations.findOne({service:'digitalocean'})
  if !config
    throw new ServiceConfiguration.ConfigError()
  try
    response = HTTP.post(
      'https://cloud.digitalocean.com/v1/oauth/token',
        headers:
          Accept: 'application/json'
          'User-Agent': userAgent
        params:
          code: query.code
          client_id: config.clientId
          client_secret: OAuth.openSecret(config.secret)
          redirect_uri: 'http://localhost:3000/_oauth/digitalocean'
          state: query.state
          grant_type: 'authorization_code'
    )

  catch err
    throw _.extend(new Error('Failed to complete OAuth handshake with DigitalOcean. ' + response.data.error))

  if response.data.error
    throw new Error('Failed to complete OAuth handshake with DigitalOcean. ' + response.data.error)
  else
    return response.data

Digitalocean.retrieveCredential = (credentialToken, credentialSecret)->
  return OAuth.retrieveCredential(credentialToken, credentialSecret)
