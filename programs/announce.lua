os.loadAPI('api/network')
os.loadAPI('api/event')

network.openAllNetworks()

print('Announcing new update..')
event.emitEvent('DEPLOY_UPDATE')

network.closeAllNetworks()
