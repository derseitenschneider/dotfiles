"use strict";var t=Object.defineProperty;var p=Object.getOwnPropertyDescriptor;var u=Object.getOwnPropertyNames;var a=Object.prototype.hasOwnProperty;var i=(r,o)=>{for(var l in o)t(r,l,{get:o[l],enumerable:!0})},n=(r,o,l,c)=>{if(o&&typeof o=="object"||typeof o=="function")for(let e of u(o))!a.call(r,e)&&e!==l&&t(r,e,{get:()=>o[e],enumerable:!(c=p(o,e))||c.enumerable});return r};var s=r=>n(t({},"__esModule",{value:!0}),r);var m={};i(m,{default:()=>f});module.exports=s(m);var d=require("@raycast/api"),f=async()=>{(0,d.open)("devutils://qrcode?clipboard")};0&&(module.exports={});