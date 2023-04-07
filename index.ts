import express from 'express'
import httpProxy from 'http-proxy'
import logger from 'morgan'

const PORT = process.env.PORT || 3000
const app = express()

app.use(logger('dev'))


const tokenProxy = httpProxy.createProxyServer({
    target: 'https://api.pawan.krd',
    changeOrigin: true
})

app.use('/backend-api/conversation', (req, res) => {
    tokenProxy.web(req, res)
})


const openAPIProxy = httpProxy.createProxyServer({
    // target: 'http://104.168.50.94:8443', // 自建海外代理节点
    target: 'https://api.openai.com',
    changeOrigin: true,
})

app.use('/', (req, res) => {
    openAPIProxy.web(req, res)
})

app.listen(PORT, () => {
    console.log('proxy on PORT', PORT)
})


