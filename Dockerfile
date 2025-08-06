FROM node:24-alpine AS builder

WORKDIR /app

# 결론은 package로 시작하는  .json 파일 전부 복사함.
COPY package*.json ./
# npm 패키지 설치
RUN npm install

# 패키지 설치하고 나온 정보들 복사 (node_modules 필요하니까)
COPY . .
# 구성한 node_modules 기반으로 build 진행
# 여기서 dist 폴더에 빌드 정보가 들어감.
RUN npm run build

# 경량형 nginx 구성
FROM nginx:alpine

# 커스텀 nginx 설정을 사용하기 위해 docker 폴더 하위의 nginx를
# 실제로 Docker Container가 구동하는 nginx 설정 파일로 복사함.
COPY docker/nginx.conf /etc/nginx/nginx.conf
# 그리고 nginx가 빌드한 결과를 구동하도록
# 빌드된 /app/dist 내용을 nginx가 구동할 /usr/share/nginx/html로 복사함.
COPY --from=builder /app/dist /usr/share/nginx/html

# nginx는 웹 서버이므로 80번 포트를 사용함
EXPOSE 80

# nginx를 구동하여 상시 구동하도록 구성
CMD ["nginx", "-g", "daemon off;"]
