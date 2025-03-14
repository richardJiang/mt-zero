package handler

import (
    "context"
	"net/http"

    "ruquan/src/gateway/internal/util"
    bizResponse "ruquan/src/util/response"
	{{.ImportPackages}}
	"github.com/tal-tech/go-zero/core/trace/tracespec"
    "github.com/tal-tech/go-zero/rest/httpx"
)

func {{.HandlerName}}(ctx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		{{if .HasRequest}}var req types.{{.RequestType}}
		if err := httpx.Parse(r, &req); err != nil {
			bizResponse.Response(w, err)
			return
		}{{end}}

		userUuid := util.GetHeaderUserUuid(r)
        c := context.WithValue(r.Context(), "userUuid", userUuid)
        c = util.CpoyHeaderToCtx(c, r)
        span := c.Value(tracespec.TracingKey).(tracespec.Trace)
        w.Header().Set("X-Trace-ID", span.TraceId())

		l := logic.New{{.LogicType}}(c, ctx)
		{{if .HasResp}}resp, {{end}}err := l.{{.Call}}({{if .HasRequest}}req{{end}})
		if err != nil {
            bizResponse.Response(w, err)
            return
        }

        bizResponse.Response(w, resp)
	}
}
